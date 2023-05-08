-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Extrae Responsables
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExtraeResponsablesInstancia] --59072,10061,3,10001,10001
    @IdInstanciaEntregable INT,
    @idUsuario INT,
    @idContrato INT,
    @idEstatus INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
		CASE ISNULL(EIA.idUsuario,'')
		WHEN  ''
		THEN a.idUsuario
		ELSE 
		EIA.idUsuario  END AS idUsuario,
           Nombre,
           Usuario
		
      FROM EN_Actividad A
      JOIN dbo.AP_Usuario U
        ON U.UsuarioID = A.idUsuario
	  LEFT JOIN EN_ExcepcionesActividad EIA ON EIA.ActividadIDExcepcion = A.ActividadID AND EIA.IdInstanciasEntregables=@IdInstanciaEntregable AND EIA.EstadoID = A.EstadoID
	  LEFT JOIN dbo.EN_InstanciasEntregable IE ON IE.idInstanciaEntregable=@IdInstanciaEntregable
	  JOIN dbo.EN_ContratoEntregable CE ON CE.IdContratoEntregable = A.IdContratoEntregable AND IE.IdContratoEntregable=A.IdContratoEntregable
     WHERE A.EstadoID             =  @idEstatus
     ORDER BY CASE ISNULL(EIA.CreadoEn,'')
		WHEN  ''
		THEN a.CreadoEn
		ELSE 
		EIA.CreadoEn  END ASC;

END;

--SELECT * FROM EN_Actividad
--SELECT * FROM dbo.EN_InstanciasEntregable
--SELECT * FROM en_estado
--SELECT * FROM AP_usuario
--Select * from en_accion