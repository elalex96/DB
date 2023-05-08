--CREATED BY: LUIS DAVID DE LA CRUZ BAUTISTA
--CREATED FOR: MODIFY 'REFACTURAS'
--CREATED AT: 09/ABRIL/2018
CREATE PROCEDURE [dbo].[SP_FACTURAS_INFORMACIONMODIFICAR]
@IDCONTRATO INT,
@IDFACTURAPADRE INT
AS
BEGIN
SELECT S.IdSubcontratista,
                    S.RazonSocial,
					RF.idFacturaPadre,
					RF.idFacturaHijo
             FROM PV_Subcontratista AS S
                  INNER JOIN FI_Factura AS F ON S.IdSubcontratista = F.IdSubcontratista
				  INNER JOIN FI_RELACIONREFACTURAS AS RF ON RF.IdFacturaHijo = F.IdFactura
             WHERE(F.IdContrato = @IDCONTRATO ) and (RF.IdfacturaPadre = @IDFACTURAPADRE)
             GROUP BY S.IdSubcontratista,
                      S.RazonSocial,
					  RF.idFacturaPadre,
					RF.idFacturaHijo
             ORDEr BY S.RazonSocial ASC;
END
