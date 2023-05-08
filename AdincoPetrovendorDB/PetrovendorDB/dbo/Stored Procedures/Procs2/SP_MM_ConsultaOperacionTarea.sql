-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaOperacionTarea]
	-- Add the parameters for the stored procedure here
	@IdTarea int
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	---validar si existen tareas nuevas 
	
		

	SELECT T.IdTarea,T.NombreTarea,  US.Nombre AS NombreAsignador, T.FechaRegistro, TipTa.NombreTipoTarea AS NombreTipoTarea,
		P.Nombre AS NombrePrioridad, T.Descripcion,
		CAST(DATEADD(day,CAST(V.DiaVencimiento AS int), T.FechaRegistro)AS date) AS FVencimient,T.IdOperacion, PR.RazonSocial
		FROM TaTarea AS T 
		JOIN TaTipoTarea TipTa ON T.IdTipoTarea = TipTa.IdTipoTarea
		JOIN TaTareaAsignador TA ON T.IdTarea = TA.IdTarea
		JOIN S_Usuario Us ON TA.IdUsuario = US.IdUsuario
		JOIN TaPrioridad P ON T.IdPrioridad = P.IdPrioridad
		JOIN TaVencimiento AS V ON V.IdVencimiento = T.IdVencimiento
		JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=TA.IdUsuario
		JOIN S_Proveedor AS PR ON PR.IdProveedor=UP.IdProveedor
		WHERE T.IdTarea = @IdTarea
   
END  
