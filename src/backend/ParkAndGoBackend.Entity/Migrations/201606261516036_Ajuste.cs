namespace ParkAndGoBackend.Entity.Migrations
{
    using System;
    using System.Data.Entity.Migrations;
    
    public partial class Ajuste : DbMigration
    {
        public override void Up()
        {
            DropIndex("Ticket.Tickets", new[] { "UserDeviceToken" });
        }
        
        public override void Down()
        {
            CreateIndex("Ticket.Tickets", "UserDeviceToken");
        }
    }
}
