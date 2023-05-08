-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_TA_InsHistorialNuevosAprobadores
@IdOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 DECLARE @t_nombres TABLE (Id INT IDENTITY(1,1),Nombre NVARCHAR(500))
	 DECLARE @Usuario_solicitante NVARCHAR(300) = (SELECT U.Nombre FROM dbo.MM_SolicitudPedido SP
												   INNER JOIN dbo.TA_Operacion O 
												   ON O.IdDocumento = SP.IdSolicitudPedido
												   INNER JOIN dbo.S_Usuario U
												   ON U.IdUsuario = SP.IdUsuarioSolicitante
												   WHERE O.IdOperacion = @IdOperacion)

		  INSERT INTO @t_nombres
		  (Nombre)
 		  SELECT U.Nombre
		  FROM dbo.TA_Tarea T
		  INNER JOIN dbo.S_Usuario U
		  ON U.IdUsuario = T.IdAprobador
		  WHERE T.IdOperacion = @IdOperacion
		  EXCEPT
		  SELECT U.Nombre 
		  FROM dbo.TA_FlujoTarea FT
		  INNER JOIN dbo.TA_Operacion O
		  ON O.IdFlujoTarea = FT.IdFlujoTarea
		  INNER JOIN dbo.TA_Aprobador A
		  ON A.IdFlujoTarea = FT.IdFlujoTarea
		  INNER JOIN dbo.S_Usuario U
		  ON U.IdUsuario = A.IdUsuario
		  WHERE O.IdOperacion = @IdOperacion   

		  DECLARE @P_S NVARCHAR(100) = (
										SELECT 
										CASE 
										WHEN COUNT(Nombre) = 1 THEN ' nuevo aprobador'
										WHEN COUNT(Nombre) > 1 THEN ' nuevos aprobadores '
										END
										FROM @t_nombres
									  )


	 --DECLARE @Nuevos_Aprobadores NVARCHAR(500) = ( SELECT Nombre + ',' AS 'data()' FROM  @t_nombres FOR XML PATH(''))
	 	 DECLARE @Nuevos_Aprobadores NVARCHAR(500) = ( 
		 SELECT
		 CASE 
		 WHEN (SELECT COUNT(Nombre) FROM @t_nombres) = 1 THEN Nombre + ','
		 WHEN (SELECT COUNT(Nombre) FROM @t_nombres) = 2 THEN Nombre + ' y'
		 WHEN (SELECT COUNT(Nombre) FROM @t_nombres) >= 3 THEN Nombre + ',' END AS 'data()'
		 FROM  @t_nombres
		 GROUP BY Nombre
		 FOR XML PATH(''))
		  
	 DECLARE @Descripcion NVARCHAR(500) =( 'El usuario ' + @Usuario_solicitante + 
	                                       ' ha agregado ' + 
										   (SELECT CAST(COUNT(Nombre) AS NVARCHAR(10)) FROM @t_nombres) + @P_S +
										   ' ('+ LEFT(@Nuevos_Aprobadores,LEN(@Nuevos_Aprobadores)-1) +') ' +
										   'a la Solicitud de pedido')

		IF ((SELECT COUNT(Nombre) FROM @t_nombres) > 0)
		BEGIN 
				INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
				VALUES(@Descripcion,@IdOperacion,GETDATE(),1)
		END
								
							


		 SELECT 'success'

     





END
