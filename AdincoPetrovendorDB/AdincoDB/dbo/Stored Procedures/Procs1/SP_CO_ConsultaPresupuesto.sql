-- =============================================
-- Author:		Marcos Garcia
-- Create date: 21-01-2020
-- Description:	Consulta Datos de CO_Presupuesto
-- =============================================
-- Create date: 12-02-2020
-- Description:	Select Activo por Actual
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ConsultaPresupuesto]
--[SP_CO_ConsultaPresupuesto] 0,0
--  the parameters for the stored procedure here 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         SELECT IdPresupuesto, 
                Nombre AS NombrePresupuesto,
                CASE
                    WHEN IdPresupuestoCNH IS NULL
                    THEN 'FALTA ID'
                    WHEN IdPresupuestoCNH = ''
                    THEN 'FALTA ID'
                    ELSE IdPresupuestoCNH
                END AS IdPresupuestoCNH,
                CASE
                    WHEN Actual = 1
                    THEN 'ACTIVO'
                    WHEN Actual IS NULL
                    THEN 'SIN ESPECIFICAR'
                    WHEN Actual = 0
                    THEN 'NO ACTIVO'
                END AS Activo,
                CASE
                    WHEN ActivoProcura = 1
                    THEN 'ACTIVO'
                    WHEN ActivoProcura IS NULL
                    THEN 'SIN ESPECIFICAR'
                    WHEN ActivoProcura = 0
                    THEN 'NO ACTIVO'
                END AS ActivoProcura, 
                InicioPresupuesto, 
                FinPresupuesto
         FROM Adinco.dbo.CO_Presupuesto (NOLOCK)
         ORDER BY IdPresupuesto DESC;
     END;