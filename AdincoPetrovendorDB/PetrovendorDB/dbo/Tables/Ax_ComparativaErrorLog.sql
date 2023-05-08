CREATE TABLE [dbo].[Ax_ComparativaErrorLog] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [IdDinamicsAx]  INT            NULL,
    [IdDocumento]   INT            NULL,
    [Motivo]        NVARCHAR (MAX) NULL,
    [FechaRegistro] DATETIME       NULL
);

