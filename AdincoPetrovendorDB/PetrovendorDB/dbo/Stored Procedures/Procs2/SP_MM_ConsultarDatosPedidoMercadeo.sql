-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/01/2021
-- Description:	Consulta de datos para la aceptiacion de servicio del pedido
-- =============================================
create PROCEDURE [dbo].[SP_MM_ConsultarDatosPedidoMercadeo] --18305,516
	-- Add the parameters for the stored procedure here
	@IdPedidoGral INT,
	@IdProveedor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdPedidoMercadeo INT = 0; 
	DECLARE @NombreProveedorVendor nvarchar(300);
	DECLARE @EXISTE_FLUJO_ACTIVO_PREDETERMINADO INT= 0;
    DECLARE @EXISTE_FLUJO NVARCHAR(50);
    DECLARE @Nacionalidad INT;
    DECLARE @NOMBRE_PROVEEDOR NVARCHAR(MAX)= '';
    DECLARE @EXISTE_FLUJO_DEA INT= 0;
    DECLARE @ISDEA BIT;

	SET @IdPedidoMercadeo = (SELECT  IdIdentificador 
								FROM dbo.MM_Pedidos  WITH (NOLOCK)
								WHERE IdPedido = @IdPedidoGral AND 
										IdProveedorCliente=@IdProveedor AND 
										IdTipoPedido IN (2,4, 6));
	--CABECERA--0
	SELECT TOP 1
		P.IdPedido,
		ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS ProveedorVendedor, 
		ISNULL(AceptacionPedidoGral,'false') AS AceptacionPedidoGral, 
		ISNULL(RecepcionServicio,'false') AS RecepcionServicio,
		ISNULL(P.Cerrado, 'false') AS PedidoCerrado,
		ISNULL(SOT.Objeto,SP.MotivoUrgencia) AS Justificacion,
		@IdPedidoMercadeo as IdPedidoMercadeo,
		sp.IdContrato, 
		sp.IdPeriodo, 
		sp.IdPresupuesto, 
		per.NombrePeriodo, 
		pre.Nombre
	FROM  dbo.MM_Pedidos AS PS WITH (NOLOCK)
		JOIN dbo.MM_Pedido AS P  WITH (NOLOCK)
			ON PS.IdIdentificador = P.IdPedido
		JOIN dbo.MM_SolicitudPedido AS SP  WITH (NOLOCK)
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido AND
				SP.IdProveedor= @IdProveedor
		JOIN dbo.S_Proveedor AS PR  WITH (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
		LEFT JOIN Adinco.dbo.CO_PeriodoContrato AS per  WITH (NOLOCK)
					ON per.IdPeriodo = sp.IdPeriodo
		LEFT JOIN Adinco.dbo.CO_Presupuesto AS pre  WITH (NOLOCK)
					ON pre.IdPresupuesto = sp.IdPresupuesto
		LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS  WITH (NOLOCK)
			ON P.IdPedido = OTS.IdPedido
		LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT  WITH (NOLOCK)
			ON OTS.IdOTSolicitud = SOT.IdOTSolicitud
	WHERE PS.IdPedido = @IdPedidoGral AND 
			PS.IdProveedorCliente= @IdProveedor AND 
			PS.IdTipoPedido IN (2,4, 6);

	--DETALLES--1
	SELECT PD.RecepcionPedido,
           PD.IdPedidoDetalle,
           PD.IdMaterialVendedor,
           M.DescripcionCorta
    FROM MM_PedidoDetalle AS PD WITH (NOLOCK)
        INNER JOIN MM_Pedido AS P WITH (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_Material AS M WITH (NOLOCK)
            ON M.IdMaterial = PD.IdMaterialVendedor
    WHERE P.IdPedido = @IdPedidoMercadeo
          AND P.IdProveedorCompras = @IdProveedor
          AND P.RecepcionServicio = 1;

	---Validación de Estatus de documentos--2

        SELECT @Nacionalidad = S.IdNacionalidad
        FROM dbo.MM_Pedido P WITH (NOLOCK)
             INNER JOIN dbo.S_Proveedor S  WITH (NOLOCK) ON S.IdProveedor = P.IdSubcontratista
        WHERE P.IdPedido = @IdPedidoMercadeo
              AND P.IdProveedorCompras = @IdProveedor;
        IF @Nacionalidad = 2

        /*NACIONALIDA EXTRANJERA*/

            BEGIN
                IF EXISTS -- se valida si el proveedor es de DEA
                (
                    SELECT 1
                    FROM dbo.DEA_Proveedor
                    WHERE IdProveedor = @IdProveedor
                )
                    BEGIN
                        SET @ISDEA = 1;
                        SET @EXISTE_FLUJO_DEA =
                        (
                            SELECT COUNT(RCFA.IdFlujoComprobante)
                            FROM dbo.MM_SolicitudPedido SP  WITH (NOLOCK)
                                 LEFT JOIN dbo.MM_Pedido P  WITH (NOLOCK) ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                                 LEFT JOIN dbo.MM_AceptacionPedido AP  WITH (NOLOCK) ON AP.IdPedido = P.IdPedido
                                 LEFT JOIN dbo.MM_SolicitudPedidoDetalle SPD  WITH (NOLOCK) ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                                 LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL  WITH (NOLOCK) ON SPDL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
                                 LEFT JOIN dbo.RelacionCentroCostoFlujoAprob RCFA  WITH (NOLOCK) ON RCFA.IdCentroCosto = SPDL.IdCentroCosto
                            WHERE P.IdPedido = @IdPedidoMercadeo
                                  AND RCFA.IdFlujoComprobante IS NOT NULL
                            GROUP BY RCFA.IdFlujoComprobante, 
                                     RCFA.IdCentroCosto
                        );
                        IF ISNULL(@EXISTE_FLUJO_DEA, 0) = 0
                            BEGIN
                                SET @EXISTE_FLUJO = 'CREAR_FLUJO';
                                SELECT @NOMBRE_PROVEEDOR = (ISNULL(S.RazonSocial, '') + ' ' + ISNULL(R.Regimen, ''))
                                FROM dbo.MM_Pedido P  WITH (NOLOCK)
                                     INNER JOIN dbo.S_Proveedor S ON S.IdProveedor = P.IdSubcontratista
                                     LEFT JOIN dbo.RegimenCapital AS R ON R.IdRegimenCapital = S.IdTipoRegimen
                                WHERE P.IdPedido = @IdPedidoMercadeo
                                      AND P.IdProveedorCompras = @IdProveedor;
                        END;
                            ELSE
                            SET @EXISTE_FLUJO = 'EXISTE_FLUJO';
                END;
                    ELSE
                    BEGIN
                        SET @ISDEA = 0;
                        SET @EXISTE_FLUJO_ACTIVO_PREDETERMINADO =
                        (
                            SELECT COUNT(F.IdFlujoTarea)
                            FROM dbo.TA_FlujoTarea F WITH (NOLOCK)
                            WHERE F.IdProveedor = @IdProveedor
                                  AND F.Activo = 1
                                  AND ISNULL(F.Eliminado, 0) = 0
                                  AND F.Predeterminado = 1
                                  AND F.IdTipoOperacion = 16
                        );

                        /*FLUJO DE PEDIMENTO O COMPROBANTE EXTRANJERO*/

                        IF @EXISTE_FLUJO_ACTIVO_PREDETERMINADO = 0
                            BEGIN
                                SET @EXISTE_FLUJO = 'CREAR_FLUJO';
                                SELECT @NOMBRE_PROVEEDOR = (ISNULL(S.RazonSocial, '') + ' ' + ISNULL(R.Regimen, ''))
                                FROM dbo.MM_Pedido P WITH (NOLOCK)
                                     INNER JOIN dbo.S_Proveedor S WITH (NOLOCK) ON S.IdProveedor = P.IdSubcontratista
                                     LEFT JOIN dbo.RegimenCapital AS R WITH (NOLOCK) ON R.IdRegimenCapital = S.IdTipoRegimen
                                WHERE P.IdPedido = @IdPedidoMercadeo
                                      AND P.IdProveedorCompras = @IdProveedor;
                        END;
                            ELSE
                            SET @EXISTE_FLUJO = 'EXISTE_FLUJO';
                END;
                SELECT CASE
                           WHEN @ISDEA = 1
                           THEN 'DEA'
                           ELSE 'EXTRANJERO'
                       END, 
                       @EXISTE_FLUJO, 
                       ISNULL(@NOMBRE_PROVEEDOR, '');
        END;
            ELSE
            BEGIN
                SELECT 'NACIONAL', 
                       '', 
                       '';
        END;

END
