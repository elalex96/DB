CREATE PROCEDURE [dbo].[sp_CO_ConsultaPeriodosContratoGastos] @IdContrato int = 0
AS
BEGIN
	--╔════════════════════════════════════════════╗
	--║Uso de SP en Sistema de ADINCO y PETROVENDOR║
	--╚════════════════════════════════════════════╝
    -- =============================================
    -- Author:		Miguel Gomez
    -- Create date: 4-01-2017
    -- Description:	Consulta los periodos de un contrato
    -- =============================================
	-- Modificado Por:			Neri del Angel
	-- Fecha de Modificación:	10 de Agosto del 2022
	-- Descripción:				Se agregan NOLOCK 
	-- =============================================
    SET NOCOUNT ON;
    SELECT IdPeriodo,
           NombrePeriodo as NombreParaMostrar
    FROM CO_PeriodoContrato (NOLOCK)
    WHERE (IdContrato = @IdContrato)
          and CO_PeriodoContrato.activo = 1
    ORDER BY inicio,
             fin
END