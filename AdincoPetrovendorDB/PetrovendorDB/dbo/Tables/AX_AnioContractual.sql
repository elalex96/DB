CREATE TABLE [dbo].[AX_AnioContractual] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [AnioLinea]     NVARCHAR (100) NULL,
    [AnioReal]      INT            NULL,
    [IdPresupuesto] INT            NULL,
    [CreadoPor]     INT            NULL,
    [FechaCreacion] DATETIME       NULL
);

