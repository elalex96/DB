CREATE PROCEDURE dbo.sp_ObtieneUsuarioReal --3,10061,285143
	@idContrato	INT,
	@idUsuario	INT,
	@idInstancia INT
AS
BEGIN
-- ============================================================
-- Modulo:			SUBIR ENTREGABLE
--------------------------------------------------------------
-- 20200229 REYNA OLVERA
-- ============================================================
SET NOCOUNT ON
	DECLARE @TextoParaMostrar	VARCHAR(MAX)='',	@CountElabora int=0;
	
	SELECT	@CountElabora	=	Count(1)
	FROM	EN_InstanciasEntregable	IE

	JOIN	EN_Actividad	A	
	ON	IE.IdContratoEntregable	=	A.IdContratoEntregable
		--AND	IE.ActividadID	=	A.ActividadID

	WHERE	IE.idInstanciaEntregable	=	@idInstancia
		AND	A.EstadoID	=	10000
		AND A.idUsuario	=	@idUsuario

			
	IF(@CountElabora	=	0)
	BEGIN
		SET	@TextoParaMostrar	=	'Entregable no asignado a su usuario.';
	END

SELECT @TextoParaMostrar AS TextoParaMostrar;
END