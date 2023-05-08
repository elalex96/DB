-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description: Actualizar el estatus de la operación relacionada con la Petición de Oferta
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarEstatusOperacionOferta]
	-- Add the parameters for the stored procedure here

	@IdOperacion int,
	@IdEstatus int output

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TOTAL_MM_PROVEEDORES_COTIZAR INT
	DECLARE @TOTAL_MM_PROVEEDORES_COTIZARON INT 


    --- Obtener Cantidad de Proveedores a los que se les envio una petición de Oferta  ---

	SET @TOTAL_MM_PROVEEDORES_COTIZAR = (SELECT COUNT(IdPeticionOferta)
							 FROM MM_PeticionOferta AS PO
							 INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
							 INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
							 WHERE O.IdOperacion= @IdOperacion)

	--- Obtener Cantidad de Proveedores que ya Cotizaron ---
	--- IdEstatus 2 Es Estatus Aprobado ---
	--- Cotizado 1 Peticion cotizada ----

	SET @TOTAL_MM_PROVEEDORES_COTIZARON = (SELECT COUNT(IdPeticionOferta)
							 FROM MM_PeticionOferta AS PO
							 INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
							 INNER JOIN TA_Operacion AS O ON O.IdDocumento = SP.IdSolicitudPedido
							 WHERE O.IdOperacion= @IdOperacion AND Cotizado=1)

	--- Validar que todos los Proveedores Cotizaron ---

	IF @TOTAL_MM_PROVEEDORES_COTIZAR = @TOTAL_MM_PROVEEDORES_COTIZARON  
		BEGIN 
			--- Actualizar estatus de la operación  ---

			UPDATE  TA_Operacion 
			SET IdEstatusOperacion= 2,
				FechaModificacion = GETDATE()
			WHERE IdOperacion= @IdOperacion 

			SET @IdEstatus = (SELECT IdEstatusOperacion
							FROM TA_Operacion
							WHERE IdOperacion= @IdOperacion)
		
        --SELECT @IdEstatus   AS EstatusOferta
			 
		END 
	ELSE
	BEGIN 

		---Retornar IdEstatusOperacion 
		--- 1 Faltan proveedores por cotizar
		--- 2 Todos los proveedores ya cotizaron su petición de oferta
	
		
		SET @IdEstatus = (SELECT IdEstatusOperacion
							FROM TA_Operacion
							WHERE IdOperacion= @IdOperacion)

	END 

	

		
	

END

