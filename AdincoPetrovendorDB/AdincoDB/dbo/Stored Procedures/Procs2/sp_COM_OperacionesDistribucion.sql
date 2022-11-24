CREATE PROCEDURE [dbo].[sp_COM_OperacionesDistribucion]
	   @IdContrato	INT,
	   @MesReporte DATE
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: Domingo 1 Diciembre 2016 19:49 p.m.
-- Description:	Reporte de Integración de Gastos a Nivel Actividad
-- =============================================
SET NOCOUNT ON 
-- =============================================


delete from COM_OPERACIONCOMERCIALIZACION   where IdContrato= @IdContrato  and  MesReporte=  @MesReporte

INSERT INTO COM_OPERACIONCOMERCIALIZACION
(
    IdContrato,
    MesReporte,
    FechaTransaccion,
    IdTipoHidrocarburo,
    VolumenVendido,
    PrecioVentaUnitario,
    CostoUnitarioComercializacion,
    PrecioPuntoMedicion,
    IdFactura,
    NumeroFolioPedimento,
    EPT,
    OperacionBajoReglasMercado,
    ClasificacionDocumentoSoporte,
    CreadoPor,
    CreadoEl,
    ModificadoPor,
    ModificadoEl,
    Activo
)
SELECT
    F.IdContrato,  --IdContrato
    @MesReporte, --MesReporte
    F.Fecha,	 --FechaTransaccion	
    PH.IdTipoHidrocarburo,  --	 IdTipoHidrocarburo	 10000: PETROLEO 10002: Metano	  10003: Etano	   10004: Propano  10005: Butano
    Cantidad * E.Factor * FDPV.Factor  ,	--VolumenVendido  
    ((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor),	 --PrecioVentaUnitario
    FDPV.CostoUnitarioComercializacion,	  --CostoUnitarioComercializacion
    (((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - FDPV.CostoUnitarioComercializacion,	--PrecioPuntoMedicion
    F.IdFactura,
    '000000000000000', --NumeroFolioPedimento
    1,  --EPT
    1,  --OperacionBajoReglasMercado
    2,  --ClasificacionDocumentoSoporte
    1,  --CreadoPor
    GETDATE(),  --CreadoEl
    1,  --ModificadoPor
    GETDATE(),  --ModificadoEl
    1   ---Activo,
FROM
    FI_FACTURA F (NOLOCK)
JOIN
    FI_CFDIConcepto    C   (NOLOCK)
    ON F.IDFACTURA = C.IDFACTURA
JOIN
    COM_Equivalencias   E
    ON  C.Unidad	=   E.Unidad
JOIN
    CO_TipoCambioDiario T
    ON  F.IdMoneda	=   T.IdMoneda
    AND CONVERT(DATE,F.Fecha)	=   T.Fecha
    JOIN COM_FacturaPuntoVenta FPV
    ON FPV.IdFactura = F.IdFactura
JOIN
    COM_PuntoVentaHidrocarburos PVH
   -- ON  SUBSTRING(F.[XML], CHARINDEX('<PuntoVenta>',F.[XML])+12, CHARINDEX('</PuntoVenta>',F.[XML])-CHARINDEX('<PuntoVenta>',F.[XML])-12)	=   PVH.NombrePuntoVenta
on pvh.IdPuntoVentaHidrocarburos  = FPV.IdPuntoVenta
JOIN
    COM_ProductoHidrocarburo	  PH
    ON  C.Descripcion   =   PH.ProductoHidrocarburo
JOIN
    COM_FactorDistribucionPuntoVenta	FDPV
    ON  PH.IdProductoHidrocarburo	 =	FDPV.IdProductoHidrocarburo
    AND F.IdContrato			 =	FDPV.IdContrato
    AND PVH.IdPuntoVentaHidrocarburos	=	  FDPV.IdPuntoVentaHidrocarburos
    AND FDPV.Mes				 =	@MesReporte
LEFT JOIN
    COM_OPERACIONCOMERCIALIZACION	 OC
    ON  F.IdFactura	=   OC.IdFactura
    AND F.IdContrato    =   OC.IdContrato
WHERE
    F.IdContrato = @IdContrato
    AND MONTH(CONVERT(DATE,F.Fecha))	=   MONTH(@MesReporte)
    AND YEAR(CONVERT(DATE,F.Fecha))	=   YEAR(@MesReporte)
    AND PH.IdTipoHidrocarburo IS NOT NULL
    AND OC.IdFactura    IS NULL
  
  --OJO Clavo aqui
  --  and F.IdFactura   in (select idfactura from COM_FacturaPuntoVenta  where idpuntoventa is not null  )

END

