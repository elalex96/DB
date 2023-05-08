create PROCEDURE SP_LINEAMIENTOS_Entidades
AS
BEGIN 
select 
		IdLineamientoEntidad, Entidad 
		FROM  EN_LineamientoEntidad
		ORDER BY Entidad asc
END