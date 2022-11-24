-- =============================================-- Author:		Miguel Gomez-- Create date: -- Description:	-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ListaPeriodosContrato]
-- Add the parameters for the stored procedure here
@IdContrato INT = 0,
@IdUsuario  INT = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from-- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT IdPeriodo,
                IdContrato,
                NombrePeriodo,
                Inicio,
                Fin,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                Activo
         FROM CO_PeriodoContrato
         WHERE idcontrato = @IdContrato ORDER BY inicio, fin;
     END;
