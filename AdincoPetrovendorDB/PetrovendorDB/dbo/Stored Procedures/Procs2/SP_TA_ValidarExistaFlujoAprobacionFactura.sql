USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ValidarExistaFlujoAprobacionFactura'
)
    DROP PROCEDURE SP_TA_ValidarExistaFlujoAprobacionFactura;
GO
/****** Object:  StoredProcedure [dbo].[SP_TA_ValidarExistaFlujoAprobacionFactura]    Script Date: 25/03/2021 12:29:58 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 25/03/2021
-- Description:	Validar exista un flujo de aprobación de factura 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ValidarExistaFlujoAprobacionFactura] 
	-- Add the parameters for the stored procedure here				
	@IdProveedor INT,
	@IdUsuario INT,
	@IdAceptacionPedido INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdFlujoAprobacion int 
	DECLARE @ID_OPERADORA INT = ( SELECT IdProveedor FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdAceptacionPedido);

	-- CONSULTAR EL FLUJO DE APROBACIÓN DEL PROCESO DE DEA
	IF EXISTS (SELECT 1 FROM dbo.DEA_Proveedor WHERE IdProveedor =@ID_OPERADORA)
	BEGIN
		-- CONSULTAMOS EL FLUJO DE APROBACION DE LA FACTURA RELACIONADO CON EL CENTRO DE COSTO DE LA REQUISICION
			       SELECT @IdFlujoAprobacion=
						RCFA.IdFlujoFactura 
					FROM dbo.MM_SolicitudPedido SP
					LEFT JOIN dbo.MM_Pedido P 
						ON P.IdSolicitudPedido = SP.IdSolicitudPedido
					LEFT JOIN dbo.MM_AceptacionPedido AP 
						ON AP.IdPedido = P.IdPedido
					LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD
						ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
					LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL
						ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
					LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA 
						ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
					WHERE AP.IdAceptacionPedido = @IdAceptacionPedido 
						AND RCFA.IdFlujoFactura IS NOT NULL
						AND RCFA.Activo = 1
					GROUP BY RCFA.IdFlujoFactura,RCFA.IdCentroCosto;

				/*SI NO SE ENCONTRO FLUJO RELACIONADO AL CENTRO DE COSTO- ASIGNAR EL PREDERTERMINADO POR LA OPERADORA*/
				IF ISNULL(@IdFlujoAprobacion,0) = 0
				BEGIN
					SELECT @IdFlujoAprobacion= FT.IdFlujoTarea
					FROM MM_AceptacionFactura AS AF
					INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
					INNER JOIN MM_Pedido   AS P on P.IdPedido= AP.IdPedido 
					INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
					INNER JOIN TA_FlujoTarea AS FT ON FT.IdProveedor =P.IdProveedorCompras
					WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND FT.IdTipoOperacion = 10 ---> APROBACIÓN FACTURA 
					AND FT.Activo=1 AND FT.Predeterminado=1
				END
	END
	ELSE
	BEGIN
	
		SELECT @IdFlujoAprobacion= FT.IdFlujoTarea
		FROM MM_AceptacionFactura AS AF
		INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN MM_Pedido   AS P on P.IdPedido= AP.IdPedido 
		INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdProveedorCompras
		INNER JOIN TA_FlujoTarea AS FT ON FT.IdProveedor =P.IdProveedorCompras
		WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND FT.IdTipoOperacion = 10 ---> APROBACIÓN FACTURA 
		AND FT.Activo=1 AND FT.Predeterminado=1

	END 

    -- Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea	
	SELECT ISNULL(@IdFlujoAprobacion,0) AS IdFlujoAprobacion

END



