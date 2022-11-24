-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_COM_CalculaFactoresPuntoVenta] 
	-- Add the parameters for the stored procedure here
@IdContrato INT  = 0,
@IdUsuario  INT  = 0,
@Mes        DATE
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         DELETE FROM COM_FactorDistribucionPuntoVenta
         WHERE IdContrato = @IdContrato
               AND Mes = @Mes;

			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
			-- Calculo Petroleo
			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
         DECLARE @VolumenPetroleoProducido INT;
         DECLARE @VolumenPetroleoCompensacion INT;
         DECLARE @VolumenPetroleoFacturado INT;
         DECLARE @PorcentajeDistribucion FLOAT;
         SELECT @VolumenPetroleoProducido = VolumenPetroleoPuntoMedicion
         FROM PR_VolumenMensualProduccionPetroleo PR
         WHERE PR.MesReporte = @Mes
               AND IdContrato = @IdContrato;
         SELECT @VolumenPetroleoCompensacion = CompensacionVolNuevoSaldoAcumuladoContratistaPetroleo
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         SELECT @VolumenPetroleoFacturado = SUM(Cantidad * E.Factor)
         FROM FI_FACTURA F(NOLOCK)
              JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
              JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
              JOIN COM_FacturaPuntoVenta FPV ON FPV.IdFactura = F.IdFactura
              JOIN COM_PuntoVentaHidrocarburos PVH -- ON  SUBSTRING(F.[XML], CHARINDEX('<PuntoVenta>',F.[XML])+12, CHARINDEX('</PuntoVenta>',F.[XML])-CHARINDEX('<PuntoVenta>',F.[XML])-12)	=   PVH.NombrePuntoVenta
              ON pvh.IdPuntoVentaHidrocarburos = FPV.IdPuntoVenta
              JOIN COM_ProductoHidrocarburo PH ON C.Descripcion = PH.ProductoHidrocarburo
         WHERE F.IdContrato = @IdContrato
               AND YEAR(F.Fecha) = YEAR(@Mes)
               AND MONTH(f.fecha) = MONTH(@Mes)
               AND IdTipoHidrocarburo = 10000
			and  FPV.idpuntoventa is not null
         GROUP BY IdContrato,
                  IdTipoHidrocarburo;
         SELECT @PorcentajeDistribucion = NuevaDistribucionProvisionalContratista
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         INSERT INTO COM_FactorDistribucionPuntoVenta
                SELECT @MES AS Mes,
                       @IdContrato AS IdContrato,
                       Ph.IdProductoHidrocarburo,
                       pv.IdPuntoVentaHidrocarburos,
                       SUM(DI.FactorDistribucionVolumetrica) AS Factor,
                       SUM(DI.FactorDistribucionVolumetrica * (((@VolumenPetroleoProducido + @VolumenPetroleoCompensacion) * (@PorcentajeDistribucion / 100)) / @VolumenPetroleoProducido)) AS FactorFinal,
                       2.09 AS CostoUnitarioComercializacion
                FROM com_areacontractualcampo ACC
                     LEFT JOIN PD_Campo C ON C.IdCampo = ACC.idcampo
                     LEFT JOIN COM_Distribucioningresos DI ON DI.clavecampo = C.clave
                     LEFT JOIN COM_ProductoHidrocarburo PH ON DI.textobrevematerial = ph.ProductoHidrocarburo
                     LEFT JOIN COM_PuntoVentaHidrocarburos PV ON pv.Clave = DI.PuntoExpedicion
                WHERE ph.IdTipoHidrocarburo = 10000
                GROUP BY Ph.IdProductoHidrocarburo,
                         pv.IdPuntoVentaHidrocarburos; 





			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
			-- Calculo Condensado
			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
         DECLARE @VolumenCondensadoProducido INT;
         DECLARE @VolumenCondensadoCompensacion INT;
         DECLARE @VolumenCondensadoFacturado INT;
    
         SELECT @VolumenCondensadoProducido = VolumenCondensadoPuntoMedicion
         FROM PR_VolumenMensualProduccionPetroleo PR
         WHERE PR.MesReporte = @Mes
               AND IdContrato = @IdContrato;
         SELECT @VolumenCondensadoCompensacion = CompensacionVolNuevoSaldoAcumuladoContratistaCondensado
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         SELECT @VolumenCondensadoFacturado = SUM(Cantidad * E.Factor)
         FROM FI_FACTURA F(NOLOCK)
              JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
              JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
              JOIN COM_FacturaPuntoVenta FPV ON FPV.IdFactura = F.IdFactura
              JOIN COM_PuntoVentaHidrocarburos PVH -- ON  SUBSTRING(F.[XML], CHARINDEX('<PuntoVenta>',F.[XML])+12, CHARINDEX('</PuntoVenta>',F.[XML])-CHARINDEX('<PuntoVenta>',F.[XML])-12)	=   PVH.NombrePuntoVenta
              ON pvh.IdPuntoVentaHidrocarburos = FPV.IdPuntoVenta
              JOIN COM_ProductoHidrocarburo PH ON C.Descripcion = PH.ProductoHidrocarburo
         WHERE F.IdContrato = @IdContrato
               AND YEAR(F.Fecha) = YEAR(@Mes)
               AND MONTH(f.fecha) = MONTH(@Mes)
               AND IdTipoHidrocarburo = 10001

			and FPV.idpuntoventa is not null
         GROUP BY IdContrato,
                  IdTipoHidrocarburo;
         SELECT @PorcentajeDistribucion = NuevaDistribucionProvisionalContratista
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         INSERT INTO COM_FactorDistribucionPuntoVenta
                SELECT @MES AS Mes,
                       @IdContrato AS IdContrato,
                       Ph.IdProductoHidrocarburo,
                       pv.IdPuntoVentaHidrocarburos,
                       SUM(DI.FactorDistribucionVolumetrica) AS Factor,
                       SUM(DI.FactorDistribucionVolumetrica * (((@VolumenCondensadoProducido + @VolumenCondensadoCompensacion) * (@PorcentajeDistribucion / 100)) / @VolumenCondensadoProducido)) AS FactorFinal,
                       2.09 AS CostoUnitarioComercializacion
                FROM com_areacontractualcampo ACC
                     LEFT JOIN PD_Campo C ON C.IdCampo = ACC.idcampo
                     LEFT JOIN COM_Distribucioningresos DI ON DI.clavecampo = C.clave
                     LEFT JOIN COM_ProductoHidrocarburo PH ON DI.textobrevematerial = ph.ProductoHidrocarburo
                     LEFT JOIN COM_PuntoVentaHidrocarburos PV ON pv.Clave = DI.PuntoExpedicion
                WHERE ph.IdTipoHidrocarburo = 10001
                GROUP BY Ph.IdProductoHidrocarburo,
                         pv.IdPuntoVentaHidrocarburos;



					


			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
			-- Calculo Metano
			--ºººººººººººººººººººººººººººººººººººººººººººººººººººººººººººººº
         DECLARE @VolumenMetanoProducido INT;
         DECLARE @VolumenMetanoCompensacion INT;
         DECLARE @VolumenMetanoFacturado INT;
    
         SELECT @VolumenMetanoProducido = MetanoC1
         FROM PR_VolumenMensualProduccionPetroleo PR
         WHERE PR.MesReporte = @Mes
               AND IdContrato = @IdContrato;
         SELECT @VolumenMetanoCompensacion = CompensacionVolNuevoSaldoAcumuladoContratistaC1
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         SELECT @VolumenMetanoFacturado = SUM(Cantidad * E.Factor)
         FROM FI_FACTURA F(NOLOCK)
              JOIN FI_CFDIConcepto C(NOLOCK) ON F.IDFACTURA = C.IDFACTURA
              JOIN COM_Equivalencias E ON C.Unidad = E.Unidad
              JOIN COM_FacturaPuntoVenta FPV ON FPV.IdFactura = F.IdFactura
              JOIN COM_PuntoVentaHidrocarburos PVH -- ON  SUBSTRING(F.[XML], CHARINDEX('<PuntoVenta>',F.[XML])+12, CHARINDEX('</PuntoVenta>',F.[XML])-CHARINDEX('<PuntoVenta>',F.[XML])-12)	=   PVH.NombrePuntoVenta
              ON pvh.IdPuntoVentaHidrocarburos = FPV.IdPuntoVenta
              JOIN COM_ProductoHidrocarburo PH ON C.Descripcion = PH.ProductoHidrocarburo
         WHERE F.IdContrato = @IdContrato
               AND YEAR(F.Fecha) = YEAR(@Mes)
               AND MONTH(f.fecha) = MONTH(@Mes)
               AND IdTipoHidrocarburo = 10001

			and FPV.idpuntoventa is not null
         GROUP BY IdContrato,
                  IdTipoHidrocarburo;
         SELECT @PorcentajeDistribucion = NuevaDistribucionProvisionalContratista
         FROM SIPAC_RM_FMP_53_M
         WHERE IdContrato = @IdContrato
               AND DATEADD(month, 1, DATEFROMPARTS(anioreporte, mesreporte, 1)) = @Mes;
         INSERT INTO COM_FactorDistribucionPuntoVenta
                SELECT @MES AS Mes,
                       @IdContrato AS IdContrato,
                       Ph.IdProductoHidrocarburo,
                       pv.IdPuntoVentaHidrocarburos,
                       SUM(DI.FactorDistribucionVolumetrica) AS Factor,
                       SUM(DI.FactorDistribucionVolumetrica * (((@VolumenMetanoProducido + @VolumenMetanoCompensacion) * (@PorcentajeDistribucion / 100)) / @VolumenMetanoProducido)) AS FactorFinal,
                       2.09 AS CostoUnitarioComercializacion
                FROM com_areacontractualcampo ACC
                     LEFT JOIN PD_Campo C ON C.IdCampo = ACC.idcampo
                     LEFT JOIN COM_Distribucioningresos DI ON DI.clavecampo = C.clave
                     LEFT JOIN COM_ProductoHidrocarburo PH ON DI.textobrevematerial = ph.ProductoHidrocarburo
                     LEFT JOIN COM_PuntoVentaHidrocarburos PV ON pv.Clave = DI.PuntoExpedicion
                WHERE ph.IdTipoHidrocarburo = 10001
                GROUP BY Ph.IdProductoHidrocarburo,
                         pv.IdPuntoVentaHidrocarburos;

     END;
