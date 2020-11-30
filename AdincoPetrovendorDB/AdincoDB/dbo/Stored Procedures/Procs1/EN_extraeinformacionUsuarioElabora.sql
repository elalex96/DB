-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/05/18
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_extraeinformacionUsuarioElabora]
	-- Add the parameters for the stored procedure here
	@InstanciaEntregableId int,
	@idUsuario int=0,
	@idContrato int=0
AS
BEGIN
	
	SET NOCOUNT ON;


	  SELECT --Nombre,
	  CASE ISNULL(EXAE.idUsuario, '')
                                WHEN ''
                                    THEN
                                    U.Nombre
                                ELSE
                                    UXE.Nombre
     END AS Nombre
	  ,--Usuario
	   CASE ISNULL(EXAE.idUsuario, '')
			WHEN ''
				THEN
				U.Usuario
			ELSE
				UXE.Usuario
     END AS Usuario,
	  --usuarioId
	  CASE ISNULL(EXAE.idUsuario, '')
			WHEN ''
				THEN
			 U.UsuarioID
			ELSE
				Uxe.UsuarioID
     END AS usuarioId
	  FROM dbo.EN_ContratoEntregable CE
	  JOIN dbo.EN_InstanciasEntregable I ON I.IdContratoEntregable = CE.IdContratoEntregable
	  JOIN dbo.EN_Actividad A ON A.IdContratoEntregable = CE.IdContratoEntregable AND A.EstadoID=10000
	  JOIN dbo.AP_Usuario U ON U.UsuarioID=A.idUsuario
	  --*************************************************************
	LEFT JOIN
		dbo.EN_ExcepcionesActividad EXAE
			ON EXAE.ActividadIDExcepcion = A.ActividadID 
				AND I.idInstanciaEntregable = EXAE.IdInstanciasEntregables 
				AND EXAE.EstadoID=10000
	LEFT JOIN
		dbo.AP_Usuario              UXE
			ON UXE.UsuarioID = EXAE.idUsuario
	 --***************************************************************
	   where idInstanciaEntregable=@InstanciaEntregableId
END
