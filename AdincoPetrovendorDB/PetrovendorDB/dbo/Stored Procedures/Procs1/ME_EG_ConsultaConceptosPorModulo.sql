-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29/01/2018>
-- Description:	<Consulta de conceptos por modulo, muestra conceptos completados o no completados por proveedor>
-- =============================================

CREATE PROCEDURE ME_EG_ConsultaConceptosPorModulo
    @IdModulo INT,
    @Completado BIT,
    @IdProveedor INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    SELECT c.IdConcepto,
           c.Concepto,
           r.Rubro,
           (CASE
                WHEN cc.Completado > 0 THEN
                    1
                ELSE
                    0
            END
           ) AS Completado
    FROM dbo.ME_EG_Conceptos c
        INNER JOIN dbo.ME_EG_ConceptosCompletados cc
            ON cc.IdConcepto = c.IdConcepto
        INNER JOIN dbo.ME_EG_Rubros r
            ON r.IdRubro = c.IdRubro
    WHERE c.IdModulo = @IdModulo
          AND (
                  cc.Completado = 0
                  OR @Completado = 1
              )
          AND cc.IdProveedor = @IdProveedor;
END;
