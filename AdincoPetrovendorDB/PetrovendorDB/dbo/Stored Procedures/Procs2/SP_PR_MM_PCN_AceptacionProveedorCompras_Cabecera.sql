-- =============================================
-- Author:		Daniel Cruz
-- Create date: 05-07-17
-- Description:	Agregue condicion para visualizar el detalle de aceptación de pedido por tipo de pedido
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 28-05-18
-- Description:	Se agrega los dias de credito al retorno
-- =============================================
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 22-09-20
-- Description:	Se agrega el tipo de pedido a la consulta
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorCompras_Cabecera]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdAceptacionPedido INT,
	@IdTipoPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdPedido INT, @CondionesPago NVARCHAR(MAX); 

	SELECT @IdPedido=AP.IdPedido
	FROM dbo.MM_AceptacionPedido AP
	LEFT JOIN dbo.MM_Pedido P 
	ON AP.IdPedido = P.IdPedido
	WHERE  P.IdProveedorCompras = @IdProveedor
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
	SELECT 
	@CondionesPago=CASE WHEN pd.IdCondicionPago = 1 THEN --> CREDITO
	CONCAT(pd.DiasCredito, CASE WHEN PD.DiasCredito=1 THEN ' días' ELSE ' días' END,' de ', cp.CondicionPago)
	ELSE 
	CONCAT(cp.CondicionPago,'')
	END 
	FROM dbo.MM_PedidoDetalle pd
	LEFT JOIN dbo.MM_CondicionPago cp 
	ON pd.IdCondicionPago = cp.IdCondicionPago
	WHERE IdPedido = @IdPedido

	
	if @IdTipoPedido != 0
	begin
    SELECT
		   AP.IdAceptacionPedido,
           AP.IdPedido,
           AP.NombreRecibidoPor,
           AP.NombreUsuarioEntrega,
           AP.Creado,
           ISNULL(PR.RazonSocial, '') + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor,
           ISNULL(AP.PCN_Agregado, 0) AS PCN_Agregado,
           ISNULL(AP.DocumentoDescargado, 0) AS DocumentoCargado,
           CONCAT(   CASE
                         WHEN DG.Calle IS NULL THEN
                             ''
                         ELSE
                             'Calle ' + DG.Calle
                     END,
                     CASE
                         WHEN DG.NoExterior IS NULL THEN
                             ''
                         ELSE
                             ' No Ext ' + DG.NoExterior
                     END,
                     CASE
                         WHEN DG.NoInterior IS NULL THEN
                             ''
                         ELSE
                             ' No Int ' + DG.NoInterior
                     END,
                     CASE
                         WHEN DG.Colonia IS NULL THEN
                             ''
                         ELSE
                             ' Colonia ' + DG.Colonia + ' '
                     END,
                     CASE
                         WHEN DG.Municipio IS NULL THEN
                             ''
                         ELSE
                             DG.Municipio + ' ,'
                     END,
                     CASE
                         WHEN DG.Estado IS NULL THEN
                             ''
                         ELSE
                             DG.Estado + ' ,'
                     END,
                     CASE
                         WHEN DG.Pais IS NULL THEN
                             ''
                         ELSE
                             DG.Pais + ' ,'
                     END,
                     CASE
                         WHEN DG.CodigoPostal IS NULL THEN
                             ''
                         ELSE
                             ' CP ' + DG.CodigoPostal
                     END
                 ) AS Direccion,
           ISNULL(AC_PCN.IdEstatus, 0) AS Estatus,
           PG.IdPedido AS IdPedidoGeneral,
		   TP.TipoPedido,
		   CASE WHEN P.UnicaCondicionPago = 1 THEN 
			CONCAT(@CondionesPago,'')
		   ELSE 
			'Diferidas para las partidas de la orden de compra'
		   END AS CondicionesPago 
    FROM MM_AceptacionPedido AS AP
        INNER JOIN DG_Domicilio AS DG
            ON AP.IdDomicilioEntrega = DG.IdDomicilio
        LEFT JOIN PV_PaisRepublica AS PS
            ON DG.IdPais = PS.id 
        INNER JOIN MM_Pedido AS P
            ON AP.IdPedido = P.IdPedido 
        INNER JOIN S_Proveedor AS PR
            ON P.IdSubcontratista = PR.IdProveedor 
        INNER JOIN MM_Pedidos AS PG
            ON P.IdPedido = PG.IdIdentificador
               --AND PG.IdTipoPedido = 2
               AND PG.IdProveedorCliente = @IdProveedor
        LEFT JOIN MM_AceptacionCartaPCN AS AC_PCN
            ON AP.IdAceptacionPedido = AC_PCN.IdAceptacionPedido
		LEFT  JOIN dbo.MM_TipoPedido AS TP 
		ON PG.IdTipoPedido = TP.IdTipoPedido
    WHERE P.IdProveedorCompras = @IdProveedor
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
		  AND pg.IdTipoPedido = @IdTipoPedido
	end
	else
	begin
	SELECT
		   AP.IdAceptacionPedido,
           AP.IdPedido,
           AP.NombreRecibidoPor,
           AP.NombreUsuarioEntrega,
           AP.Creado,
           ISNULL(PR.RazonSocial, '') + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor,
           ISNULL(AP.PCN_Agregado, 0) AS PCN_Agregado,
           ISNULL(AP.DocumentoDescargado, 0) AS DocumentoCargado,
           CONCAT(   CASE
                         WHEN DG.Calle IS NULL THEN
                             ''
                         ELSE
                             'Calle ' + DG.Calle
                     END,
                     CASE
                         WHEN DG.NoExterior IS NULL THEN
                             ''
                         ELSE
                             ' No Ext ' + DG.NoExterior
                     END,
                     CASE
                         WHEN DG.NoInterior IS NULL THEN
                             ''
                         ELSE
                             ' No Int ' + DG.NoInterior
                     END,
                     CASE
                         WHEN DG.Colonia IS NULL THEN
                             ''
                         ELSE
                             ' Colonia ' + DG.Colonia + ' '
                     END,
                     CASE
                         WHEN DG.Municipio IS NULL THEN
                             ''
                         ELSE
                             DG.Municipio + ' ,'
                     END,
                     CASE
                         WHEN DG.Estado IS NULL THEN
                             ''
                         ELSE
                             DG.Estado + ' ,'
                     END,
                     CASE
                         WHEN DG.Pais IS NULL THEN
                             ''
                         ELSE
                             DG.Pais + ' ,'
                     END,
                     CASE
                         WHEN DG.CodigoPostal IS NULL THEN
                             ''
                         ELSE
                             ' CP ' + DG.CodigoPostal
                     END
                 ) AS Direccion,
           ISNULL(AC_PCN.IdEstatus, 0) AS Estatus,
           PG.IdPedido AS IdPedidoGeneral,
		   TP.TipoPedido,
		   CASE WHEN P.UnicaCondicionPago = 1 THEN 
			CONCAT(@CondionesPago,'')
		   ELSE 
			'Diferidas para las partidas de la orden de compra'
		   END AS CondicionesPago 
    FROM MM_AceptacionPedido AS AP
        INNER JOIN DG_Domicilio AS DG
            ON AP.IdDomicilioEntrega = DG.IdDomicilio
        LEFT JOIN PV_PaisRepublica AS PS
            ON DG.IdPais = PS.id
        INNER JOIN MM_Pedido AS P
            ON AP.IdPedido = P.IdPedido 
        INNER JOIN S_Proveedor AS PR
            ON P.IdSubcontratista = PR.IdProveedor
        INNER JOIN MM_Pedidos AS PG
            ON P.IdPedido = PG.IdIdentificador
               --AND PG.IdTipoPedido = 2
               AND PG.IdProveedorCliente = @IdProveedor
        LEFT JOIN MM_AceptacionCartaPCN AS AC_PCN
            ON AP.IdAceptacionPedido = AC_PCN.IdAceptacionPedido 
		LEFT  JOIN dbo.MM_TipoPedido AS TP 
		ON PG.IdTipoPedido = TP.IdTipoPedido
    WHERE P.IdProveedorCompras = @IdProveedor
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
	end
END