CREATE TABLE [dbo].[MA_Prioridad] (
    [IdPrioridad]      INT            IDENTITY (1, 1) NOT NULL,
    [Prioridad]        NVARCHAR (300) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      BIT            NULL,
    [IdContrato]       INT            NULL,
    [IdSubcontratista] INT            NULL,
    [Activo]           BIT            NULL,
    CONSTRAINT [PK_MA_Prioridad] PRIMARY KEY CLUSTERED ([IdPrioridad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

