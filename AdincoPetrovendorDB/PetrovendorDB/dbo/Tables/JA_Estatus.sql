CREATE TABLE [dbo].[JA_Estatus] (
    [CreadoPor]   INT           NULL,
    [Estatus]     INT           NULL,
    [FechaCreado] SMALLDATETIME NULL,
    [IdEstatus]   INT           IDENTITY (1, 1) NOT NULL,
    [IdProveedor] INT           NULL,
    [IdTopic]     INT           NULL
);

