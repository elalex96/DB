CREATE TABLE [dbo].[MA_Vigencia] (
    [IdVigencia]       INT            IDENTITY (1, 1) NOT NULL,
    [Vigencia]         NVARCHAR (300) NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEl]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEl]     DATETIME       NULL,
    [IsEliminado]      BIT            NULL,
    [IdContrato]       INT            NULL,
    [IdSubcontratista] INT            NULL,
    [Activo]           BIT            NULL,
    CONSTRAINT [PK_MA_Vigencia] PRIMARY KEY CLUSTERED ([IdVigencia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

