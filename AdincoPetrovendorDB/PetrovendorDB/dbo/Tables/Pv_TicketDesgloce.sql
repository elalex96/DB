CREATE TABLE [dbo].[Pv_TicketDesgloce] (
    [Cantidad]                    DECIMAL (18)   NULL,
    [Comentario]                  NVARCHAR (MAX) NULL,
    [Descripcion]                 NVARCHAR (MAX) NULL,
    [FinEjecucion]                DATETIME       NULL,
    [Folio]                       NVARCHAR (150) NULL,
    [IdCentroCosto]               INT            NULL,
    [IdCuentaContable]            INT            NULL,
    [IdCuentaSectorHidrocarburos] INT            NULL,
    [IdInstalacion]               INT            NULL,
    [IdLineaPresupuesto]          INT            NULL,
    [IdTicket]                    INT            NULL,
    [IdTicketDesgloce]            INT            IDENTITY (1, 1) NOT NULL,
    [Importe]                     DECIMAL (18)   NULL,
    [InicioEjecucion]             DATETIME       NULL,
    [ValorUnitario]               DECIMAL (18)   NULL
);

