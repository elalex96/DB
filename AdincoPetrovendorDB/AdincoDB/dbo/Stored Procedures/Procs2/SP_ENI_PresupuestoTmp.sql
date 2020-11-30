-- =============================================
-- Author:		Manuel Cruz
-- Create date: 14-05-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_PresupuestoTmp] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         --     SELECT idActividadPetrolera,
         --            ActividadPetrolera,
         --            idSubActividadPetrolera,
         --            SubActividadPetrolera,
         --            [ANO1(2017-2018)],
         --            [ANO2(2019)],
         --            [ANO3(2020)],
         --            [ANO4(2021)],
         --            [ANO5(2022)],
         --Total
         --     FROM ENI_PresupuestoTmp;
         SELECT idActividadPetrolera, 
                ActividadPetrolera, 
                idSubActividadPetrolera, 
                SubActividadPetrolera, 
                Base1, 
                Contingente1, 
                Base2, 
                Contingente2, 
                NULL AS [ANO1(2017-2018)], 
                NULL AS [ANO2(2019)], 
                NULL AS [ANO3(2020)], 
                NULL AS [ANO4(2021)], 
                NULL AS [ANO5(2022)], 
                NULL AS Total
         FROM dbo.ENI_PresupuestoTmp2020;
     END;