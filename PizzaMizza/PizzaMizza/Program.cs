using System;
using System.Data;
using Microsoft.Data.SqlClient;

class Program
{
    private static readonly string ConnString = @"Server=localhost,1433;Database=PizzaMizzaDB;User Id=sa;Password=StrongTural88725;TrustServerCertificate=True";

    static void Main()
    {
        tryAgain:
        Console.WriteLine("Seçim edin: 1 = Oxu, 2 = Yaz");
        string choice = Console.ReadLine()?.Trim();
        Console.Clear();
        try
        {
            using (var connection = new SqlConnection(ConnString))
            {
                connection.Open();

                switch (choice)
                {
                    case "1":
                        ReadPizzas(connection);
                        goto tryAgain;

                    case "2":
                        Console.WriteLine("Pizzanin adini daxil edin:");
                        string name = Console.ReadLine();
                        Console.WriteLine("Pizzanin tipini daxil edin:");
                        string type = Console.ReadLine();
                        Console.WriteLine("Pizzanin olcusunu daxil edin:");
                        string sizeName = Console.ReadLine();
                        Console.WriteLine("Pizzanin qiymetini daxil edin:");
                        decimal price = Convert.ToDecimal(Console.ReadLine());

                        int pizzaId = AddPizzaWithPrice(connection, name, type, sizeName, price);
                        Console.WriteLine($"Yeni Pizza ID: {pizzaId}");
                        goto tryAgain;

                    default:
                        Console.WriteLine("Yanlış seçim. 1 və ya 2 daxil edin.");
                        goto tryAgain;
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Xəta: {ex.Message}");
            goto tryAgain;
        }
    }

    private static void ReadPizzas(SqlConnection connection)
    {
        string sqlRead = @"
            SELECT p.Name, p.Type, pp.Price
            FROM dbo.Pizzas p
            LEFT JOIN dbo.PizzaPrices pp ON p.ID = pp.PizzaID
            ORDER BY p.ID, pp.SizeID";

        using (var readCmd = new SqlCommand(sqlRead, connection))
        using (var reader = readCmd.ExecuteReader())
        {
            while (reader.Read())
            {
                string name = reader.IsDBNull(0) ? "Unknown" : reader.GetString(0);
                string type = reader.IsDBNull(1) ? "Unknown" : reader.GetString(1);
                decimal? price = reader.IsDBNull(2) ? null : reader.GetDecimal(2);

                Console.WriteLine($"{name} ({type}) - Qiymət: {(price.HasValue ? price.Value.ToString("0.00") : "Yoxdur")}");
            }
        }
    }

    // Yazma metodu: pizza əlavə edir və seçilmiş size üçün qiymət əlavə edir. Yeni pizza ID-ni qaytarır.
    private static int AddPizzaWithPrice(SqlConnection connection, string name, string type, string sizeName, decimal price)
    {
        using (var tran = connection.BeginTransaction())
        {
            try
            {
                string sqlWritePizza = @"
                    INSERT INTO dbo.Pizzas (Name, Type)
                    VALUES (@name, @type);
                    SELECT CAST(SCOPE_IDENTITY() AS INT);";

                int newPizzaId;
                using (var writeCmd = new SqlCommand(sqlWritePizza, connection, tran))
                {
                    writeCmd.Parameters.Add("@name", SqlDbType.NVarChar, 100).Value = name;
                    writeCmd.Parameters.Add("@type", SqlDbType.NVarChar, 50).Value = type;

                    newPizzaId = (int)writeCmd.ExecuteScalar();
                }

                int sizeId;
                string sqlGetSizeId = @"SELECT ID FROM dbo.Sizes WHERE Name = @sizeName;";
                using (var sizeCmd = new SqlCommand(sqlGetSizeId, connection, tran))
                {
                    sizeCmd.Parameters.Add("@sizeName", SqlDbType.NVarChar, 50).Value = sizeName;
                    var obj = sizeCmd.ExecuteScalar();
                    if (obj == null)
                        throw new InvalidOperationException("Göstərilən ölçü tapılmadı. 'Sizes' cədvəlini 'Small/Medium/Large' ilə doldurun.");

                    sizeId = (int)obj;
                }

                string sqlWritePrice = @"
                    INSERT INTO dbo.PizzaPrices (PizzaID, SizeID, Price)
                    VALUES (@pizzaId, @sizeId, @price);
                    SELECT CAST(SCOPE_IDENTITY() AS INT);";

                using (var priceCmd = new SqlCommand(sqlWritePrice, connection, tran))
                {
                    priceCmd.Parameters.Add("@pizzaId", SqlDbType.Int).Value = newPizzaId;
                    priceCmd.Parameters.Add("@sizeId", SqlDbType.Int).Value = sizeId;

                    var priceParam = priceCmd.Parameters.Add("@price", SqlDbType.Decimal);
                    priceParam.Precision = 10;
                    priceParam.Scale = 2;
                    priceParam.Value = price;

                    priceCmd.ExecuteScalar();
                }

                tran.Commit();
                return newPizzaId;
            }
            catch
            {
                tran.Rollback();
                throw;
            }
        }
    }
}