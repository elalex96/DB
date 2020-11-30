CREATE PROCEDURE [dbo].[Mobile_Licitaciones] 
@IdRondaSelected INT
AS
BEGIN    
	SELECT 
	idRonda 'IdLicitacion',CoIdRonda 'IdRonda',
	CONCAT('Licitación ' ,REPLACE(Ronda,'Ronda','')) 'Licitacion' 
	FROM dbo.EN_Rondas
	WHERE CoIdRonda=@IdRondaSelected
	order by Ronda
end