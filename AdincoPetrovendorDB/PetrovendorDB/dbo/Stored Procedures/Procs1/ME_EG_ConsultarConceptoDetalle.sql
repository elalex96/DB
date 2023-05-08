-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29/01/2018>
-- Description:	<Consulta el detalle de los conceptos y se muestra la opcion que el proveedor ha ingresado>
-- =============================================

CREATE PROCEDURE ME_EG_ConsultarConceptoDetalle
    @IdConcepto INT,
    @IdProveedor INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    SELECT cd.IdConceptoDetalle,
           cd.Detalle,
           cd.Puntos,
           (CASE
                WHEN cd.Puntos = cc.Completado THEN
                    1
                ELSE
                    0
            END
           ) AS Completado
    FROM dbo.ME_EG_ConceptosDetalle cd
        INNER JOIN dbo.ME_EG_ConceptosCompletados cc
            ON cc.IdConcepto = cd.IdConcepto
    WHERE cc.IdProveedor = @IdProveedor
          AND cd.IdConcepto = @IdConcepto;
END;
