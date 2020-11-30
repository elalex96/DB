-- =============================================
-- Author:Daniel AC
-- Create date: 26-09-2019
-- Description: Se agregaron parametros referencias al s3
-- =============================================
CREATE PROCEDURE [dbo].[SP_GuardarRespaldosFactura]
(
    @idFactura INT,
    @documento NVARCHAR(MAX),
	@nombreArchivo NVARCHAR(MAX),
	@Carpeta NVARCHAR(max),
	@Mime NVARCHAR(MAX),
	@Identificador NVARCHAR(MAX),
	@Extension NVARCHAR(MAX)
)
AS
BEGIN
    INSERT INTO dbo.Pv_DocSoporte_CompraDirecta
    (
        idFactura,
        documento,
        nombreArchivo,
		Carpeta,
		Mime,
		Extension,
		Identificador
    )
    VALUES
    (   @idFactura,   -- idFactura - int
        @documento, -- documento - nvarchar(max)
        @nombreArchivo,  -- nombreArchivo - nvarchar(max)
		@Carpeta,
		@Mime,
		@Extension, 
		@Identificador 
    )
    
    
END