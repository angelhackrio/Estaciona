namespace ParkAndGoBackend.Entity.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class Novidades : DbMigration
    {
        public override void Up()
        {
            AddColumn("Ticket.Tickets", "UserDeviceToken", c => c.String(nullable: false));
            AddColumn("Ticket.Tickets", "IntervaloComprado", c => c.Int(nullable: false));
            AlterColumn("Ticket.Tickets", "PrecoPagoEmCentavos", c => c.Long(nullable: false));
            //CreateIndex("Ticket.Tickets", "UserDeviceToken");
        }
        
        public override void Down()
        {
            //DropIndex("Ticket.Tickets", new[] { "UserDeviceToken" });
            AlterColumn("Ticket.Tickets", "PrecoPagoEmCentavos", c => c.Int(nullable: false));
            DropColumn("Ticket.Tickets", "IntervaloComprado");
            DropColumn("Ticket.Tickets", "UserDeviceToken");
        }
    }
}
