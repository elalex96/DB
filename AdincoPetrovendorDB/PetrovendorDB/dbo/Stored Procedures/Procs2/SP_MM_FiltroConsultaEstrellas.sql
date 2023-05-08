-- =============================================
-- Author:		DANIEL AC
-- Create date: 20-09-17
-- Description:	Consultar FILTRO DE ESTRELLAS
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_FiltroConsultaEstrellas]


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 CREATE TABLE #ESTRELLAS(IdEstrellas INT ,Cantidad INT, ESTRELLAS NVARCHAR(MAX))

	 INSERT INTO #ESTRELLAS (IdEstrellas,Cantidad, ESTRELLAS)
	 VALUES(6, 6, 'Todos'),
	 (5, 5, 'Cinco Estrellas'),
	 (4, 4, 'Cuatro Estrellas'),
	 (3, 3, 'Tres Estrellas'),
	 (2, 2, 'Dos Estrellas'),
	 (1, 1, 'Una Estrella'),
	 (0, 0, 'Ninguna Estrella')

	 
	 
	 
	 

	 SELECT * FROM #ESTRELLAS

 
END
 
 
