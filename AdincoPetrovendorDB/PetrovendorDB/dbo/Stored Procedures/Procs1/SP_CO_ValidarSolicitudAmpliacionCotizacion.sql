-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/05/2018
-- Description:	Validacion para mostrar la opcion de envio de solicitud de ampliacion del plazo de cotizacion
-- =============================================
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <18-10-2018>
-- Description:	<se modifica el store para que tenga en cuenta la operacion eliminada>
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ValidarSolicitudAmpliacionCotizacion]
	-- Add the parameters for the stored procedure here
	@IdProvedor INT, @IdPeticionOferta INT ,
	@IdContrato INT = NULL, 
	@IdUsuario INT = NULL, 
	@FechaRegistro DATETIME = NULL

AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;
		DECLARE @response NVARCHAR(20) = '' ;
		DECLARE @DISPONIBILIDAD NVARCHAR(MAX)  = '' ;
		DECLARE @ESTATUSCOTIZACION NVARCHAR(MAX)  = '' ;

		SET @ESTATUSCOTIZACION  =
					(	SELECT		CASE WHEN PO.Cotizado = 1 THEN
											 'Cotizada'
									WHEN PO.Cotizado = 0 THEN
										'No Cotizada'
									WHEN PO.Cotizado IS NULL
										 AND PO.NoCotizar IS NULL
										 AND DATEDIFF ( MINUTE, O.FechaFinalizacion, GETDATE ()) < 0 THEN
										'En cotización'
									WHEN PO.Cotizado IS NULL
										 AND DATEDIFF ( MINUTE, O.FechaFinalizacion, GETDATE ()) >= 0 THEN
										'Vencida'
									END AS EstatusCotizacion
						FROM	MM_PeticionOferta AS PO
						JOIN	MM_SolicitudPedido AS SP (NOLOCK)
							ON PO.IdSolicitudPedido = SP.IdSolicitudPedido  
						JOIN	TA_Operacion AS O (NOLOCK)
							ON PO.IdSolicitudPedido = O.IdDocumento
						WHERE
									PO.IdPeticionOferta = @IdPeticionOferta
									AND O.IdTipoOperacion = 6 -->CTE
									AND O.FechaFinalizacion IS NOT NULL
									AND ISNULL ( PO.Visible, 1 ) = 1
									AND ISNULL ( O.IdEstatusEliminado, 0 ) = 0 )

		SET @DISPONIBILIDAD  =
					(	SELECT		TOP 1
									CASE WHEN PED.IdPedido IS NULL THEN
											 'Cotización Abierta'
									WHEN PED.IdPedido IS NOT NULL THEN
										'Cotización Cerrada'
									END AS Disponibilidad
						FROM		MM_PeticionOferta AS PO
						JOIN	MM_SolicitudPedido AS SP (NOLOCK)
							ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
						JOIN	TA_Operacion AS O (NOLOCK)
							ON PO.IdSolicitudPedido =O.IdDocumento
						LEFT JOIN	dbo.MM_Pedido AS PED (NOLOCK)
							ON PO.IdSolicitudPedido = PED.IdSolicitudPedido
						LEFT JOIN	dbo.MM_Pedido AS PEDD (NOLOCK)
							ON PO.IdPeticionOferta = PEDD.IdPeticionOferta
						WHERE
									PO.IdPeticionOferta = @IdPeticionOferta
									AND O.IdTipoOperacion = 6 --> CTE
									AND O.FechaFinalizacion IS NOT NULL
									AND ISNULL ( PO.Visible, 1 ) = 1
									AND ISNULL ( O.IdEstatusEliminado, 0 ) = 0
						ORDER BY	PED.FechaEnvioPedido ASC )

		

		IF @ESTATUSCOTIZACION = 'Vencida'
		   AND	@DISPONIBILIDAD = 'Cotización Abierta'
			BEGIN
				DECLARE @SOLICITUDENVIADA INT =
							(	SELECT	ISNULL ( AmpliacionPor, 0 )
								FROM	dbo.MM_PeticionOferta
								WHERE	IdPeticionOferta = @IdPeticionOferta )

				IF @SOLICITUDENVIADA = 0 BEGIN
					SET @response = N'MOSTRAR OPCION'
				END				ELSE 
				BEGIN
					SET @response = N'SOLICITUD ENVIADA'
				END
			END

		SELECT @response
	END