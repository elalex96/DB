CREATE TABLE [dbo].[PV_Ticket] (
    [CreadoPor]              INT      NULL,
    [FechaCreacion]          DATETIME NULL,
    [Folio]                  INT      NULL,
    [IdRazonSocialProveedor] INT      NULL,
    [IdTicket]               INT      IDENTITY (1, 1) NOT NULL
);

