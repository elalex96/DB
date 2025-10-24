USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..USP_SEL_MM_CalculoPlantillaSE') IS NOT NULL
BEGIN
DROP PROCEDURE USP_SEL_MM_CalculoPlantillaSE;
END
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 07/10/2025
-- Description:	Calculo de VNMO, VS, VMO y partidas para la plantilla de soporte SE
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_MM_CalculoPlantillaSE]
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @CantidadTiposXAceptacion INT = (SELECT 
											COUNT(DISTINCT (tmp.Descripcion))
										FROM dbo.MM_AceptacionPedidoDetalle APD (NOLOCK)
											JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
												ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
												AND APD.IdAceptacionPedido = @IdAceptacionPedido
											LEFT JOIN dbo.MM_Material mat (NOLOCK)
												ON PD.IdMaterialVendedor = mat.IdMaterial
											LEFT JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
												ON tmp.IdTipoMaterialProcura = mat.IdTipoCatalogoMaestro);

DECLARE @TipoServicioMaterial INT = 3;--PARA MANEJAR BIENES Y SERVICIOS (2 PLANTILLAS)
DECLARE @TipoMaterial INT = (SELECT IdTipoMaterialProcura FROM MM_TipoMaterialProcura WHERE Descripcion = 'Material');
DECLARE @TipoServicio INT = (SELECT IdTipoMaterialProcura FROM MM_TipoMaterialProcura WHERE Descripcion = 'Servicio');
DECLARE @CartaProveedorProveedor BIT = 0;
DECLARE @IdContrato INT;

SELECT TOP 1
		@IdContrato = PD.IdContrato
	FROM dbo.MM_AceptacionPedido AS AP (NOLOCK)
		JOIN dbo.S_Proveedor AS P (NOLOCK) 
			ON AP.IdProveedor = P.IdProveedor
		JOIN MM_Pedido AS PD (NOLOCK) 
			ON AP.IdPedido = PD.IdPedido
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

--VERIFICACIÓN DE CARTA DE PROVEEDOR A PROVEEDOR
IF EXISTS (SELECT
				TipoConfiguracion
			FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
			WHERE IdContrato = @IdContrato
				AND TipoConfiguracion = 'CARTA_PR_PR'
				AND Operadora = 1
				AND Activo = 1)
BEGIN
    SET @CartaProveedorProveedor = 1;
END

IF (@CantidadTiposXAceptacion = 2)
    BEGIN
        ---CABECERA MATERIAL
        SELECT
	        SUM(PCNV.ValorFactura) AS ValorFacturaTotal,
	        SUM(PCNV.VNMO_SueldoNacional) AS VNMO_SueldoNacionalTotal,
	        SUM(PCNV.VMO_Sueldo) AS VMO_SueldoTotal,
	        AP.IdAceptacionPedido,
            CASE 
                WHEN @CartaProveedorProveedor = 1 THEN 'COMISION NACIONAL DE HIDROCARBUROS'
                ELSE  PR.RazonSocial
            END AS Asignatario,
            PRS.RazonSocial AS NombreProveedor,
            PRS.RFC,
            CO.NumeroContrato
        FROM MM_PCN_ValoresPesos AS PCNV
	        JOIN MM_AceptacionPedidoDetalle AS APD
		        ON PCNV.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
	        JOIN MM_AceptacionPedido AS AP
		        ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                    AND AP.IdAceptacionPedido = @IdAceptacionPedido
            JOIN MM_Pedido AS P (NOLOCK)
                ON AP.IdPedido = P.IdPedido
            JOIN S_Proveedor AS PR (NOLOCK)
                ON P.IdProveedorCompras = PR.IdProveedor
            JOIN S_Proveedor AS PRS (NOLOCK)
                ON P.IdSubContratista = PRS.IdProveedor
            JOIN Adinco..CO_Contrato AS CO (NOLOCK)
                ON P.IdContrato = CO.IdContrato
            JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
				ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
            JOIN dbo.MM_Material mat (NOLOCK)
				ON PD.IdMaterialVendedor = mat.IdMaterial
			JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
				ON tmp.IdTipoMaterialProcura = mat.IdTipoCatalogoMaestro
                AND tmp.IdTipoMaterialProcura = @TipoMaterial
        GROUP BY AP.IdAceptacionPedido,
                    PR.RazonSocial,
                    PRS.RazonSocial,
                    PRS.RFC,
                    CO.NumeroContrato

        --CABECERA SERVICIOS
        SELECT
	        SUM(PCNV.ValorFactura) AS ValorFacturaTotal,
	        SUM(PCNV.VNMO_SueldoNacional) AS VNMO_SueldoNacionalTotal,
	        SUM(PCNV.VMO_Sueldo) AS VMO_SueldoTotal,
	        AP.IdAceptacionPedido,
            CASE 
                WHEN @CartaProveedorProveedor = 1 THEN 'COMISION NACIONAL DE HIDROCARBUROS'
                ELSE  PR.RazonSocial
            END AS Asignatario,
            PRS.RazonSocial AS NombreProveedor,
            PRS.RFC,
            CO.NumeroContrato
        FROM MM_PCN_ValoresPesos AS PCNV (NOLOCK)
	        JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		        ON PCNV.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
	        JOIN MM_AceptacionPedido AS AP (NOLOCK)
		        ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                    AND AP.IdAceptacionPedido = @IdAceptacionPedido
            JOIN MM_Pedido AS P (NOLOCK)
                ON AP.IdPedido = P.IdPedido
            JOIN S_Proveedor AS PR (NOLOCK)
                ON P.IdProveedorCompras = PR.IdProveedor
            JOIN S_Proveedor AS PRS (NOLOCK)
                ON P.IdSubContratista = PRS.IdProveedor
            JOIN Adinco..CO_Contrato AS CO (NOLOCK)
                ON P.IdContrato = CO.IdContrato
            JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
				ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
            JOIN dbo.MM_Material mat (NOLOCK)
				ON PD.IdMaterialVendedor = mat.IdMaterial
			JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
				ON tmp.IdTipoMaterialProcura = mat.IdTipoCatalogoMaestro
                AND tmp.IdTipoMaterialProcura = @TipoServicio
        GROUP BY AP.IdAceptacionPedido,
                    PR.RazonSocial,
                    PRS.RazonSocial,
                    PRS.RFC,
                    CO.NumeroContrato

        --MATERIALES
        SELECT 
             ROW_NUMBER() OVER (ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS IdRow,
		     tmp.Descripcion AS Tipo, 
		     MU.Descripcion AS DescripciónMaterial, 
             MU.NombreProveedor AS NombreProveedor,
             '' AS EspacioEnBlanco,--SE DEJA ESPACIO EN BLANCO YA QUE LA PLANTILLA TIENE UNA COBINACION DE COLUMNAS QUE NO SE PERMITE EDITAR
             MU.RFC, 
             ISNULL(MU.VM_ValorFactura,0) AS ValorFactura, 
		     ISNULL(MU.PCNM_Utilizado,0) AS ProporcionCN
	     FROM MM_PCN_MaterialesUtilizados  AS MU
	     INNER JOIN MM_PCN_ValoresPesos AS V (NOLOCK)
		    ON MU.IdValoresEnPesosPedidoDetalle = V.IdValoresEnPesosPedidoDetalle
	     JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		    ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
         JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
			        ON MU.IdTipoMaterial = tmp.IdTipoMaterialProcura
	     WHERE APD.IdAceptacionPedido = @IdAceptacionPedido
         AND MU.IdTipoMaterial = @TipoMaterial
	     AND ISNULL(MU.IsEliminado,0)=0


         ---SERVICIOS
         SELECT 
             ROW_NUMBER() OVER (ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS IdRow,
		     tmp.Descripcion AS Tipo, 
		     MU.Descripcion AS DescripciónMaterial, 
             MU.NombreProveedor AS NombreProveedor,
             MU.RFC, 
             ISNULL(MU.VM_ValorFactura,0) AS ValorFactura, 
		     ISNULL(MU.PCNM_Utilizado,0) AS ProporcionCN
	     FROM MM_PCN_MaterialesUtilizados  AS MU (NOLOCK)
	     INNER JOIN MM_PCN_ValoresPesos AS V (NOLOCK)
		    ON MU.IdValoresEnPesosPedidoDetalle = V.IdValoresEnPesosPedidoDetalle
	     JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		    ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
         JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
			        ON MU.IdTipoMaterial = tmp.IdTipoMaterialProcura
	     WHERE APD.IdAceptacionPedido = @IdAceptacionPedido
         AND MU.IdTipoMaterial = @TipoServicio
	     AND ISNULL(MU.IsEliminado,0)=0

    END;
    ELSE
    BEGIN

        SET @TipoServicioMaterial =
        (   SELECT DISTINCT
                   (tmp.IdTipoMaterialProcura)
            FROM dbo.MM_AceptacionPedidoDetalle APD (NOLOCK)
                JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
                    ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
                LEFT JOIN dbo.MM_Material mat (NOLOCK)
                    ON PD.IdMaterialVendedor = mat.IdMaterial
                LEFT JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
                    ON tmp.IdTipoMaterialProcura = mat.IdTipoCatalogoMaestro
            WHERE IdAceptacionPedido = @IdAceptacionPedido
                  AND mat.IdTipoCatalogoMaestro IS NOT NULL
            GROUP BY (tmp.IdTipoMaterialProcura));

         --CABECERA
        SELECT
	        SUM(PCNV.ValorFactura) AS ValorFacturaTotal,
	        SUM(PCNV.VNMO_SueldoNacional) AS VNMO_SueldoNacionalTotal,
	        SUM(PCNV.VMO_Sueldo) AS VMO_SueldoTotal,
	        AP.IdAceptacionPedido,
            CASE 
                WHEN @CartaProveedorProveedor = 1 THEN 'COMISION NACIONAL DE HIDROCARBUROS'
                ELSE  PR.RazonSocial
            END AS Asignatario,
            PRS.RazonSocial AS NombreProveedor,
            PRS.RFC,
            CO.NumeroContrato, 
            @TipoServicioMaterial AS Tipo
        FROM MM_PCN_ValoresPesos AS PCNV (NOLOCK)
	        JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		        ON PCNV.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
	        JOIN MM_AceptacionPedido AS AP (NOLOCK)
		        ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
                    AND AP.IdAceptacionPedido = @IdAceptacionPedido
            JOIN MM_Pedido AS P (NOLOCK)
                ON AP.IdPedido = P.IdPedido
            JOIN S_Proveedor AS PR (NOLOCK)
                ON P.IdProveedorCompras = PR.IdProveedor
            JOIN S_Proveedor AS PRS (NOLOCK)
                ON P.IdSubContratista = PRS.IdProveedor
            JOIN Adinco..CO_Contrato AS CO (NOLOCK)
                ON P.IdContrato = CO.IdContrato
        GROUP BY AP.IdAceptacionPedido,
                    PR.RazonSocial,
                    PRS.RazonSocial,
                    PRS.RFC,
                    CO.NumeroContrato

        --PARTIDAS
        IF @TipoServicioMaterial = @TipoMaterial
        BEGIN

            --MATERIALES
            SELECT 
                 ROW_NUMBER() OVER (ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS IdRow,
		         tmp.Descripcion AS Tipo, 
		         MU.Descripcion AS DescripciónMaterial, 
                 MU.NombreProveedor AS NombreProveedor,
                 '' AS EspacioEnBlanco,--SE DEJA ESPACIO EN BLANCO YA QUE LA PLANTILLA TIENE UNA COBINACION DE COLUMNAS QUE NO SE PERMITE EDITAR
                 MU.RFC, 
                 ISNULL(MU.VM_ValorFactura,0) AS ValorFactura, 
		         ISNULL(MU.PCNM_Utilizado,0) AS ProporcionCN
	         FROM MM_PCN_MaterialesUtilizados  AS MU (NOLOCK)
	         INNER JOIN MM_PCN_ValoresPesos AS V (NOLOCK)
		        ON MU.IdValoresEnPesosPedidoDetalle = V.IdValoresEnPesosPedidoDetalle
	         JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		        ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
             JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
			            ON MU.IdTipoMaterial = tmp.IdTipoMaterialProcura
	         WHERE APD.IdAceptacionPedido = @IdAceptacionPedido
             AND MU.IdTipoMaterial = @TipoMaterial
	         AND ISNULL(MU.IsEliminado,0)=0

        END
        ELSE
        BEGIN
            
             ---SERVICIOS
             SELECT 
                 ROW_NUMBER() OVER (ORDER BY APD.IdAceptacionPedidoDetalle ASC) AS IdRow,
		         tmp.Descripcion AS Tipo, 
		         MU.Descripcion AS DescripciónMaterial, 
                 MU.NombreProveedor AS NombreProveedor,
                 MU.RFC, 
                 ISNULL(MU.VM_ValorFactura,0) AS ValorFactura, 
		         ISNULL(MU.PCNM_Utilizado,0) AS ProporcionCN
	         FROM MM_PCN_MaterialesUtilizados  AS MU
	         INNER JOIN MM_PCN_ValoresPesos AS V (NOLOCK)
		        ON MU.IdValoresEnPesosPedidoDetalle = V.IdValoresEnPesosPedidoDetalle
	         JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
		        ON V.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
             JOIN dbo.MM_TipoMaterialProcura tmp (NOLOCK)
			            ON MU.IdTipoMaterial = tmp.IdTipoMaterialProcura
	         WHERE APD.IdAceptacionPedido = @IdAceptacionPedido
             AND MU.IdTipoMaterial = @TipoServicio
	         AND ISNULL(MU.IsEliminado,0)=0

        END
          

    END

END
