-- =============================================
-- Author:		Pedro AcuÒa
-- Create date: 12/06/2019
-- Description:	Obtner las instalaciones filtradas por el contrato sin que muestre el comodin que utiliza la operadora 
-- comodin se refiere a que cuando estan en operacion no saben a que pozo aun va los materiales y en la solped escogen ese para despues modificarlo
-- =============================================

CREATE PROCEDURE [dbo].[Cmb_ObtenerInstalacionSinComodin] @IdContrato INT
AS
    BEGIN
        SELECT
                i.IdInstalacion, i.NombreInstalacion
        FROM
                Adinco.dbo.CO_Instalacion AS i
            INNER JOIN
                Adinco.dbo.CO_Contrato    AS c
                    ON c.IdAreaContractual = i.IdAreaContractual
        WHERE
                c.IdContrato = @IdContrato
               -- AND ISNULL(i.EsBolsa, 0) = 0
				AND ISNULL(i.Activo,0) = 1
    END
