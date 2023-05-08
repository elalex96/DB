-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tarea				
-- =============================================
-- Author:		Jose Roman
-- Create date: 16-08-2018
-- Description:	Se agrega la consulta del telefono				
-- =============================================
--************************************************************** 
-- Modified:    LUIS DAVID
-- Updated date: 22/02/2022
-- Description: Se agrega el idusuarioAdinco para notificaciones push
--************************************************************** 
--************************************************************** 
-- Modified:    Alexander GOMEZ
-- Updated date: 18/05/2022
-- Description: se realiza una secuencia de acuerdo a los usuarios activos
--************************************************************** 
CREATE  PROCEDURE [dbo].[SP_TA_ConsultarFlujoTareaAprobadores]
	-- Add the parameters for the stored procedure here
	 @IdFlujoTarea int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT 
		A.IdUsuario, 
		IdFlujoTarea, 
		ROW_NUMBER() OVER(ORDER BY NoSecuencia ASC) AS NoSecuencia, 
		Nombre, 
		Correo, 
		ISNULL(U.Telefono, ''),
		U.IdUsuarioADINCO
	 FROM TA_Aprobador AS A
	 INNER JOIN S_Usuario AS U 
		ON U.IdUsuario = A.IdUsuario 
			AND U.Activo = 1 
			AND ISNULL(U.IsEliminado,0) = 0
	 WHERE A.IdFlujoTarea = @IdFlujoTarea
	 ORDER BY  NoSecuencia ASC

END

