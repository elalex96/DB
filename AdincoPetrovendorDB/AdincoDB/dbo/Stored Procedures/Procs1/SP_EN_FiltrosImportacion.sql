-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de filtros de importacion de entregables>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_FiltrosImportacion] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@FILTRO NVARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @FILTRO = 'ML'
	BEGIN
		
		SELECT
			ML.IdMarcoLegal,
			ML.MarcoLegal
		FROM dbo.EN_ContratoEntregable AS CE
			JOIN dbo.EN_Entregable AS E ON CE.IdEntregable = E.IdEntregable
											AND ISNULL(E.IsActivo,0) = 1
											AND CE.Activo = 1
			JOIN dbo.EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal
		WHERE CE.IdContrato = @IdContrato
		GROUP BY ML.IdMarcoLegal,
			ML.MarcoLegal;

	END

	IF @FILTRO = 'AR'
	BEGIN
		
		SELECT
			A.idArea,
			A.NombreArea
		FROM dbo.EN_Area AS A
		WHERE A.idContrato = @IdContrato    
		GROUP BY A.idArea,
			A.NombreArea;

	END

	IF @FILTRO = 'E'
	BEGIN
		
		select  u.UsuarioID,  
			u.Nombre   
		 from  Ap_Usuario   u  
		 inner join AP_PerfilUsuario pu  
		 on   u.UsuarioID   = pu.UsuarioID  
		 inner join AP_Perfil   p  
		 on   p.IdPerfil   = pu.PerfilID  
		 where  p.IdContrato  = @IdContrato  
		 AND ISNULL(IsGrupo,0)=0;

	END
END
