CREATE TABLE [dbo].[TA_FlujoTareaConstante] (
    [IdConstante]     INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]          NVARCHAR (300) NULL,
    [IdTipoOperacion] INT            NULL,
    CONSTRAINT [PK_TaFlujoTareaConstante] PRIMARY KEY CLUSTERED ([IdConstante] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

