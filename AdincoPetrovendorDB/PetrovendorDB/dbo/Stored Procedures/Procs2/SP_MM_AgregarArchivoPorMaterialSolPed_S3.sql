-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- Author:	DANIEL AC
-- Create date: 27/04/2018
-- Description:	AGREGAR NUEVO MATERIAL DE SOLICITUD PEDIDO DETALLE 
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018>
-- Description:	<Se agrega el guardado del usuario que carga el documento y la fecha de carga>
-- =============================================

CREATE PROCEDURE SP_MM_AgregarArchivoPorMaterialSolPed_S3
    @IdSolPedDetalle INT,
    @ArchivoAdjunto NVARCHAR(MAX),
    @NombreAdjunto NVARCHAR(MAX),
	@IdUsuario INT,
    /*NUEVOS PARAMETROS */
    @Mime NVARCHAR(MAX),
    @Carpeta NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @IdentificadorS3 NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    INSERT INTO MM_SolPedArchivoAdjuntoMaterial
    (
        IdSolPedDetalle,
        ArchivoAdjuntoMaterial,
        NombreArchivoAdjunto,
        Carpeta,
        Identificador,
        Mime,
        Extension,
        Activo,
		CreadoPor,
		CreadoEl
    )
    VALUES
    (
		@IdSolPedDetalle, 
		@ArchivoAdjunto, 
		@NombreAdjunto, 
		@Carpeta, 
		@IdentificadorS3, 
		@Mime, 
		@Extension, 
		1,
		@IdUsuario,
		GETDATE()
	);

    SELECT @@IDENTITY;
END;
