CREATE TABLE [dbo].[PC_TipoExcelPemex] (
    [IdTipoExcelPemex]   INT           IDENTITY (10000, 1) NOT NULL,
    [NombreTipo]         NVARCHAR (50) NULL,
    [CreadoPor]          INT           NULL,
    [CreadoEn]           DATETIME      NULL,
    [EdicionRestringida] BIT           NULL,
    [CountColumnas]      INT           NULL,
    CONSTRAINT [PK_PC_TipoExcelPemex] PRIMARY KEY CLUSTERED ([IdTipoExcelPemex] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

