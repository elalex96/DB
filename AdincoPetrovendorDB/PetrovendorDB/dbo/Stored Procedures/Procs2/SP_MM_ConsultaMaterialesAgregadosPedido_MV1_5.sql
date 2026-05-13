-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Materiales que se quieren agregar al pedido de manera Temp 
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <17-04-2018>
-- Description:	<Se agrega el IsNull al regimen capital por si no cuenta con el devuelva la razon social y no lo deje vacio>
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialesAgregadosPedido_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdSolicitudPedido INT,
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    SET NOCOUNT ON;


    SELECT POD.IdPeticionOfertaDetalle,
           CONCAT (MSP.DescripcionCorta,
                   ' Marca: ', CASE WHEN ISNULL(LEN(MSP.Marca),0)>0 THEN MSP.Marca ELSE ' S/M' END,
                   ' Modelo: ', CASE WHEN ISNULL(LEN(MSP.Modelo),0)>0 THEN MSP.Modelo ELSE ' S/M' END,
                   ' No. Parte: ',CASE WHEN ISNULL(LEN(MSP.NumeroParte),0)>0 THEN MSP.NumeroParte  ELSE ' S/NP' END ) AS Material,--MSP.DescripcionCorta AS Material,
           POD.NoMaterialesRequeridos,
           CONCAT (M.DescripcionCorta,
                   ' Marca: ', CASE WHEN ISNULL(LEN(M.Marca),0)>0 THEN M.Marca ELSE ' S/M' END,
                   ' Modelo: ', CASE WHEN ISNULL(LEN(M.Modelo),0)>0 THEN M.Modelo ELSE ' S/M' END,
                   ' No. Parte: ',CASE WHEN ISNULL(LEN(M.NumeroParte),0)>0 THEN M.NumeroParte  ELSE ' S/NP' END ) AS MaterialCotizado,--M.DescripcionCorta
           PrecioUnitario,
           POD.Disponibilidad,
           POD.AddCantidadTemp,
           POD.AddSubTotalTemp,
           (P.RazonSocial + ' ' + ISNULL(P.RegimenCapital, '')) AS NombreProveedor,
           P.IdProveedor,
           TM.TipoMonedaCorto AS Moneda,
		   UM.Unidad AS UnidadMaterial,
		   UMP.Unidad AS UnidadMaterialCotizado,
		   CASE
               WHEN ISNULL(CP.IdCondicionPago, 0) = 0 THEN
                  'No definido'
               WHEN  ISNULL(CP.IdCondicionPago, 0) = 1 THEN 
			     CONCAT(CP.CondicionPago,' ', POD.DiasCredito, ' día(s)')
			   WHEN ISNULL(CP.IdCondicionPago, 0) = 2 THEN 
                  CP.CondicionPago
           END AS CondicionPagoCotizacion
    FROM MM_PeticionOfertaDetalle AS POD
        INNER JOIN MM_PeticionOferta AS PO
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
        INNER JOIN MM_Material AS M
            ON M.IdMaterial = POD.IdMaterialVendedor
        INNER JOIN S_Proveedor AS P
            ON P.IdProveedor = POD.IdProveedorVenta
        INNER JOIN MM_SolicitudPedido AS SP
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD
            ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
        INNER JOIN dbo.MM_Material AS MSP
            ON MSP.IdMaterial = SPD.IdMaterial
               AND POD.IdMaterial = MSP.IdMateriaL
        LEFT JOIN dbo.PV_TipoMoneda TM
            ON TM.IdMoneda = POD.IdMoneda
	    LEFT JOIN dbo.PV_MM_MaterialUnidad AS UM ON UM.IdUnidad=POD.IdUnidad
		LEFT JOIN dbo.PV_MM_MaterialUnidad AS UMP ON UMP.IdUnidad=POD.IdUnidadProveedor
		LEFT JOIN dbo.MM_CondicionPago CP ON CP.IdCondicionPago=POD.IdCondicionPago
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND POD.AddPedidoTemp = 1
    GROUP BY POD.IdPeticionOfertaDetalle,
             MSP.DescripcionCorta,
             POD.NoMaterialesRequeridos,
             M.DescripcionCorta,
             PrecioUnitario,
             POD.Disponibilidad,
             POD.AddCantidadTemp,
             POD.AddSubTotalTemp,
             P.RazonSocial,
             P.RegimenCapital,
             P.IdProveedor,
             TM.TipoMonedaCorto,
			 UM.Unidad,
		     UMP.Unidad ,
			 MSP.Marca,
			 MSP.Modelo,
			 MSP.NumeroParte,
			 M.Marca,
			 M.Modelo,
			 M.NumeroParte,
			 CP.IdCondicionPago,
			 CP.CondicionPago,
			 POD.DiasCredito	 
    ORDER BY M.DescripcionCorta;

END;


