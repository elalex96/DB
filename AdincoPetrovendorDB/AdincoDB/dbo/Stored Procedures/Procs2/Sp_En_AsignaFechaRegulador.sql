-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/06/2019
-- Description:	Asigna la fecha de regulador
-- =============================================

CREATE PROCEDURE [dbo].[Sp_En_AsignaFechaRegulador] --10061,3
    @idUsuario INT,
    @idContrato INT,
    @InstanciaEntregableId INT,
	@FechaRegulador DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
	UPDATE 
	dbo.EN_InstanciasEntregable
	SET FechaRealEntregaRegulador	=	@FechaRegulador,
		ModificadoPor	=	@idUsuario,
		ModificadoEn	=	GETDATE()
	WHERE idInstanciaEntregable=@InstanciaEntregableId

END;


