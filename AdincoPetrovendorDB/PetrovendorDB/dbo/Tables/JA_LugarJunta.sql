CREATE TABLE [dbo].[JA_LugarJunta] (
    [CreadoPor]   INT            NULL,
    [Domicilio]   NVARCHAR (MAX) NULL,
    [FechaCreado] SMALLDATETIME  NULL,
    [IdLugar]     INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor] INT            NULL
);

