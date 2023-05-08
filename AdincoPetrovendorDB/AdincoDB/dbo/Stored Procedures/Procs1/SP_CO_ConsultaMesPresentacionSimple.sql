CREATE PROCEDURE [dbo].[SP_CO_ConsultaMesPresentacionSimple] 
AS
BEGIN
	SET LANGUAGE SPANISH
    SELECT	MesPresentacion AS MesPresentacion,
		CONCAT( datename(month, IdFecha), ' ', YEAR(IdFecha)) AS Mes
      FROM CO_Registro	R
	  JOIN
		AP_CALENDARIO	C
		ON	R.MesPresentacion	=	C.IdFecha
	  WHERE MesPresentacion IS NOT NULL
	  GROUP BY	
	  MesPresentacion ,
	  CONCAT( datename(month, C.IdFecha), ' ', YEAR(C.IdFecha)),C.IdFecha
     ORDER BY  C.IdFecha  DESC 
END;

