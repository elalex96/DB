-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 17-04-17
-- Description:	SP que agrega Peticion de Oferta
-- UPDATE:	SE CAMBIO CARGA DE DETALLE DE ARCHIVO A SP INDEPENDIENTE 
-- =============================================
-- Update Author:	Alexander Gomez
-- Update date: 03/07/2019
-- Description:	se agrego la variable y guardado de la restriccion de cotizacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarPeticionOferta]
		
		
		@IdSolicitudPedido int, 
		@IdProveedor int, 
        @IdUsuario INT,
		@IdTipoProceso INT,
		@JustificacionAdjDirecta NVARCHAR(MAX),
		@CotizacionRestringida BIT
		--@DocAdjDirecta NVARCHAR(MAX) MOD S3

     
AS
BEGIN

		IF(@JustificacionAdjDirecta = '')
			SET @JustificacionAdjDirecta = NULL
	

    DECLARE @IdPeticionOferta int

	SET NOCOUNT ON;
    INSERT INTO MM_PeticionOferta(IdSolicitudPedido,IdSubcontratista,CreadoPor,CreadoEl,Activo,Visto,Iniciada,IdTipoProceso,JustificacionAdjDirecta,CotizacionRestringida)
    VALUES(@IdSolicitudPedido,@IdProveedor,@IdUsuario,GETDATE(),1,1,0,@IdTipoProceso,@JustificacionAdjDirecta,@CotizacionRestringida)
				
	SELECT  @@IDENTITY AS IdPeticionOferta

END
