-- =============================================
-- Author:		daniel ac
-- Create date: 07-03-2018
-- Description:	Se guarda documento para una Solicitud de pedido
-- =============================================
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <11-09-2018>
-- Description:	<se agrega el bit de activo o inactivo>
-- =============================================
CREATE procedure [dbo].[API_MM_SP_GuardarDocumentoSolPed]

	@IdSolPed INT,
	@Documento NVARCHAR(max),
	@Nombre varchar(100),	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	
AS
BEGIN
	
	INSERT INTO dbo.MM_DocumentosSolPed
	(
	    IdSolPed,
	    Documento,
	    NombreDoc,
		Activo
	)
	VALUES
	(   @IdSolPed,   -- IdSolPed - int
	    @Documento, -- Documento - nvarchar(max)
	    @Nombre,   -- NombreDoc - varchar(100)
		1
	)

END