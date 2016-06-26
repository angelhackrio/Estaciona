namespace ParkAndGoBackend.Entity.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class MaisTabelas : DbMigration
    {
        public override void Up()
        {
            CreateTable(
                "Pagamento.DetalhePagamentos",
                c => new
                    {
                        Id = c.Guid(nullable: false),
                        PagoComSucesso = c.Boolean(nullable: false),
                        CartaoDeCreditoSalvo_Id = c.Guid(),
                    })
                .PrimaryKey(t => t.Id)
                .ForeignKey("Pagamento.SavedCreditCards", t => t.CartaoDeCreditoSalvo_Id)
                .Index(t => t.CartaoDeCreditoSalvo_Id);
            
            CreateTable(
                "Pagamento.SavedCreditCards",
                c => new
                    {
                        Id = c.Guid(nullable: false),
                        IdOfSavedCardInTheGateway = c.String(nullable: false),
                        CreditCardBrand = c.Int(nullable: false),
                        MaskedCreditCardNumber = c.String(nullable: false, maxLength: 24),
                        UserDeviceId = c.Guid(nullable: false),
                        _createdAt = c.DateTimeOffset(nullable: false, precision: 7),
                    })
                .PrimaryKey(t => t.Id)
                .ForeignKey("User.UserDevices", t => t.UserDeviceId, cascadeDelete: true)
                .Index(t => t.UserDeviceId);
            
            CreateTable(
                "User.UserDevices",
                c => new
                    {
                        Id = c.Guid(nullable: false),
                        Token = c.String(nullable: false),
                    })
                .PrimaryKey(t => t.Id);
            
            CreateTable(
                "Ticket.Tickets",
                c => new
                    {
                        Id = c.Guid(nullable: false),
                        EstacionamentoId = c.Guid(nullable: false),
                        PlacaDoCarro = c.String(nullable: false, maxLength: 7),
                        DataInicioDoSlot = c.DateTimeOffset(nullable: false, precision: 7),
                        DataFimDoSlot = c.DateTimeOffset(nullable: false, precision: 7),
                        PrecoPagoEmCentavos = c.Int(nullable: false),
                        DetalhePagamentoId = c.Guid(nullable: false),
                        _createdAt = c.DateTimeOffset(nullable: false, precision: 7),
                        _changedAt = c.DateTimeOffset(precision: 7),
                        _rowVersion = c.Binary(nullable: false, fixedLength: true, timestamp: true, storeType: "rowversion"),
                    })
                .PrimaryKey(t => t.Id)
                .ForeignKey("Pagamento.DetalhePagamentos", t => t.DetalhePagamentoId, cascadeDelete: true)
                .ForeignKey("Estacionamento.Estacionamentos", t => t.EstacionamentoId, cascadeDelete: true)
                .Index(t => t.EstacionamentoId)
                .Index(t => t.PlacaDoCarro)
                .Index(t => t.DataInicioDoSlot)
                .Index(t => t.DetalhePagamentoId);
            
            AddColumn("Estacionamento.Estacionamentos", "IntervaloEmHoras", c => c.Int(nullable: false));
            AlterColumn("Estacionamento.Estacionamentos", "PrecoDoIntervaloEmCentavos", c => c.Long(nullable: false));
        }
        
        public override void Down()
        {
            DropForeignKey("Ticket.Tickets", "EstacionamentoId", "Estacionamento.Estacionamentos");
            DropForeignKey("Ticket.Tickets", "DetalhePagamentoId", "Pagamento.DetalhePagamentos");
            DropForeignKey("Pagamento.DetalhePagamentos", "CartaoDeCreditoSalvo_Id", "Pagamento.SavedCreditCards");
            DropForeignKey("Pagamento.SavedCreditCards", "UserDeviceId", "User.UserDevices");
            DropIndex("Ticket.Tickets", new[] { "DetalhePagamentoId" });
            DropIndex("Ticket.Tickets", new[] { "DataInicioDoSlot" });
            DropIndex("Ticket.Tickets", new[] { "PlacaDoCarro" });
            DropIndex("Ticket.Tickets", new[] { "EstacionamentoId" });
            DropIndex("Pagamento.SavedCreditCards", new[] { "UserDeviceId" });
            DropIndex("Pagamento.DetalhePagamentos", new[] { "CartaoDeCreditoSalvo_Id" });
            AlterColumn("Estacionamento.Estacionamentos", "PrecoDoIntervaloEmCentavos", c => c.Int(nullable: false));
            DropColumn("Estacionamento.Estacionamentos", "IntervaloEmHoras");
            DropTable("Ticket.Tickets");
            DropTable("User.UserDevices");
            DropTable("Pagamento.SavedCreditCards");
            DropTable("Pagamento.DetalhePagamentos");
        }
    }
}
