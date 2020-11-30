CREATE TABLE [dbo].[PC_ExcelPemex] (
    [IdExcelPemex]     INT            IDENTITY (10000, 1) NOT NULL,
    [IdTipoExcelPemex] INT            NULL,
    [NombreArchivo]    NVARCHAR (MAX) NULL,
    [FechaReporte]     DATE           NULL,
    [ExcelArchivo]     IMAGE          NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    [IdContrato]       INT            NULL,
    CONSTRAINT [PK_PC_ExcelPemex] PRIMARY KEY CLUSTERED ([IdExcelPemex] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_ExcelPemex_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_PC_ExcelPemex_PC_TipoExcelPemex] FOREIGN KEY ([IdTipoExcelPemex]) REFERENCES [dbo].[PC_TipoExcelPemex] ([IdTipoExcelPemex])
);


GO
CREATE NONCLUSTERED INDEX [idx_IdTipoExcelPemex]
    ON [dbo].[PC_ExcelPemex]([IdTipoExcelPemex] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

