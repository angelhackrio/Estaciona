namespace ParkAndGoBackend.Entity.Migrations
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Migrations;
    using System.Linq;

    internal sealed class Configuration : DbMigrationsConfiguration<ParkAndGoBackend.Entity.ParkAndGoDbContext>
    {
        public Configuration()
        {
            AutomaticMigrationsEnabled = false;
        }

        protected override void Seed(ParkAndGoBackend.Entity.ParkAndGoDbContext db)
        {
            //  This method will be called after migrating to the latest version.

            //  You can use the DbSet<T>.AddOrUpdate() helper extension method 
            //  to avoid creating duplicate seed data. E.g.
            //
            //    context.People.AddOrUpdate(
            //      p => p.FullName,
            //      new Person { FullName = "Andrew Peters" },
            //      new Person { FullName = "Brice Lambson" },
            //      new Person { FullName = "Rowan Miller" }
            //    );
            //

            var es = new Estacionamento.Estacionamento
            {
                Id = Guid.Parse("790BC38E-F59A-438E-8144-EBC0A86F68D1"),
                Nome = "Zona Azul",
                EmpresaResponsavel = "Rio Park",
                Descricao = "Rio Park é o estaci.... Seg a Sexta pago",
                PrecoDoIntervaloEmCentavos = 200,
                IntervaloEmHoras = 2
            };
            db.Estacionamentos.AddOrUpdate(es);

           

        }
    }
}
