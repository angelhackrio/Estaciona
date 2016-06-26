namespace ParkAndGoBackend.Entity.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class Initial : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "Estacionamento.Estacionamentos",
                c => new
                    {
                        Id = c.Guid(nullable: false),
                        Nome = c.String(nullable: false, maxLength: 256),
                        Descricao = c.String(nullable: false, maxLength: 1024),
                        EmpresaResponsavel = c.String(nullable: false, maxLength: 256),
                        PrecoDoIntervaloEmCentavos = c.Int(nullable: false),
                    })
                .PrimaryKey(t => t.Id);
            
        }
        
        public override void Down()
        {
            DropTable("Estacionamento.Estacionamentos");
        }
    }
}
