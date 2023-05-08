-- ==
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Elimina Procesos de Macroproceso
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_EliminaProcesosDeMacro] --10009,11048,10061,3
    @IdProceso INT,--MAcroprocesos
	@MacroProceso INT,
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

Delete From  EN_MacroProcesosRelacion
where idProcesoHijo=@IdProceso AND idMacroProceso=@MacroProceso;
END;
