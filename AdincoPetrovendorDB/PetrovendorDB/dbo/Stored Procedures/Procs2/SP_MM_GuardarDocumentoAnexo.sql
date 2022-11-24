
-- =============================================
-- Author:		<>
-- Update date: <>
-- Description:	<>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <07-11-2018>
-- Description:	<Se agrega el dato de guardado por y creado el >
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_GuardarDocumentoAnexo]
    @IdPedido INT,
    @IdPedidoDetalle INT,
    @Documento NVARCHAR(MAX),
    @Nombre VARCHAR(MAX),
	@IdUsuario INT,
	/*NUEVOS PARAMETROS*/
	@Carpeta NVARCHAR(MAX),
	@Identificador  NVARCHAR(MAX), 
	@Extension NVARCHAR(MAX),
	@Mime NVARCHAR(MAX),
	@Bucket NVARCHAR(MAX)
AS
BEGIN

    INSERT INTO dbo.MM_DocumentosAnexos
    (
        IdPeticionOferta,
        IdPeticionOfertaDetalle,
        Documento,
        Nombre,
		Carpeta,
		Identificador,
		Extension,
		Mime,
		Activo,
		CreadoEl,
		CreadoPor,
		Bucket
    )
    VALUES
    (   @IdPedido,        -- IdPedido - int
        @IdPedidoDetalle, -- IdPedidoDetalle - int
        @Documento,       -- Documento - nvarchar(max)
        @Nombre ,          -- Nombre - varchar(max)
		@Carpeta,
		@Identificador,
		@Extension,
		@Mime,
		1,
		GETDATE(),
		@IdUsuario,
		@Bucket
    ) 

END