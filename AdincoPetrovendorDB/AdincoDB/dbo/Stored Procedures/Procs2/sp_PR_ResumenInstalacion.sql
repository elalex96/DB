/****** Object:  StoredProcedure [dbo].[ResumenInstalacion]    Script Date: 26/03/2017 06:42:54 p. m. ******/
CREATE PROCEDURE [dbo].[sp_PR_ResumenInstalacion] 
	-- Add the parameters for the stored procedure here
	@instalacion INT = 0 , @ID INT
AS
BEGIN
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
	DECLARE @Tabla_Temp TABLE (Indice INT , Categoria NVARCHAR(max), Etiqueta NVARCHAR(max), Valor  NVARCHAR(max))
	DECLARE  @Bruta AS  MONEY
	DECLARE  @Neta AS  MONEY 
	DECLARE  @DifBruta AS  MONEY
	DECLARE  @DifNeta AS  MONEY
	DECLARE  @parosactivos AS INT
	DECLARE  @rubroparo AS INT 
	DECLARE  @idparo AS INT 

	SET NOCOUNT ON;

	--BLOQUE
	IF @instalacion = 1 
		BEGIN
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(0, '01 General','Clave:', (SELECT  rtrim(Clave)  FROM PR_Bloque WHERE Id =  @ID ) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(1, '01 General','Nombre:', (	SELECT Nombre   FROM PR_Bloque WHERE Id =  @ID )  )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(2, '02 Pozos','Productores:', (SELECT COUNT(1) FROM  PR_Pozo INNER JOIN  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id GROUP BY PR_Ramal.Bloque, PR_Pozo.Estatus HAVING (PR_Ramal.Bloque = @ID) and (PR_Pozo.Estatus = 9 ) ))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(3, '02 Pozos','Espera enganche:', (SELECT COUNT(1) FROM  PR_Pozo INNER JOIN  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id GROUP BY PR_Ramal.Bloque, PR_Pozo.Estatus HAVING (PR_Ramal.Bloque = @ID) and (PR_Pozo.Estatus = 503 ) ))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(4, '02 Pozos','Cerrados con posibilidad:', (	SELECT COUNT(1) FROM  PR_Pozo INNER JOIN  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id GROUP BY PR_Ramal.Bloque, PR_Pozo.Estatus HAVING (PR_Ramal.Bloque = @ID) and (PR_Pozo.Estatus = 120 ) ))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(5, '02 Pozos','Cerrados sin posibilidad:', (	SELECT COUNT(1) FROM  PR_Pozo INNER JOIN  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id GROUP BY PR_Ramal.Bloque, PR_Pozo.Estatus HAVING (PR_Ramal.Bloque = @ID) and (PR_Pozo.Estatus = 121 ) ))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(6, '02 Pozos','Total:', (SELECT COUNT(1) FROM  PR_Pozo INNER JOIN  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id GROUP BY PR_Ramal.Bloque HAVING (PR_Ramal.Bloque = @ID)   ))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)
			 VALUES(7, '04 Paros','Abiertos:', (SELECT COUNT(1) FROM         PR_Ramal INNER JOIN
				PR_Estacion ON PR_Ramal.Id = PR_Estacion.Ramal INNER JOIN
				PR_Pozo ON PR_Estacion.Id = PR_Pozo.Estacion INNER JOIN
				PR_Paro ON PR_Pozo.Id = PR_Paro.Pozo
				GROUP BY PR_Ramal.Bloque, PR_Paro.Finalizado
				HAVING      (PR_Ramal.Bloque = @ID) AND (PR_Paro.Finalizado = 0)))
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(8, '04 Paros','Cerrados:', (	SELECT    CONVERT(VARCHAR,  CAST(   COUNT(1) AS MONEY), 1)  FROM         PR_Ramal INNER JOIN
				PR_Estacion ON PR_Ramal.Id = PR_Estacion.Ramal INNER JOIN
				PR_Pozo ON PR_Estacion.Id = PR_Pozo.Estacion INNER JOIN
				PR_Paro ON PR_Pozo.Id = PR_Paro.Pozo
				GROUP BY PR_Ramal.Bloque, PR_Paro.Finalizado
				HAVING      (PR_Ramal.Bloque = @ID) AND (PR_Paro.Finalizado = 1)))
				
			SELECT @Bruta = CAST( (SELECT     ROUND(SUM(PR_Pozo.ProduccionBruta), 2) 
				FROM         PR_Pozo INNER JOIN
					   PR_Campo ON PR_Pozo.Campo = PR_Campo.Id INNER JOIN
					   PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
					   PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id
				WHERE     (PR_Pozo.Estatus = 9) AND (PR_Pozo.SubEstado <> 449) AND (PR_Ramal.Bloque = 1)) AS MONEY)             
				
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(9, '03 Producción','Suma Contable BBDP:',  CONVERT(VARCHAR,  CAST( @Bruta AS MONEY), 1)      )
			
			SELECT @Neta = CAST( (SELECT     ROUND(SUM(PR_Pozo.ProduccionNeta ), 2) 
				FROM         PR_Pozo INNER JOIN
									  PR_Campo ON PR_Pozo.Campo = PR_Campo.Id INNER JOIN
									  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
									  PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id
				WHERE     (PR_Pozo.Estatus = 9) AND (PR_Pozo.SubEstado <> 449) AND (PR_Ramal.Bloque = 1)) AS MONEY )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(12, '03 Producción','Suma Contable BNDP:',  CONVERT(VARCHAR,  CAST(@Neta  AS MONEY), 1) )
				
			SELECT @DifBruta = CAST( (SELECT   sum(PR_ParoDetalle.ProduccionDiferidaB) 
				FROM         PR_Paro INNER JOIN
									  PR_ParoDetalle ON PR_Paro.Id = PR_ParoDetalle.IdParo INNER JOIN
									  PR_Pozo ON PR_Paro.Pozo = PR_Pozo.Id INNER JOIN
									  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
									  PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id INNER JOIN
									  PR_ListaGeneral ON PR_Pozo.TipoSistema = PR_ListaGeneral.Id INNER JOIN
									  PR_RubroParo ON PR_Paro.Motivo = PR_RubroParo.Id
				WHERE     (PR_ParoDetalle.Inicio >= DATEADD(HOUR, 5, CAST(CAST(GETDATE() AS DATE) AS datetime))) AND (PR_ParoDetalle.Inicio < DATEADD(DAY, 1, DATEADD(hour, 5, 
									  CAST(CAST(GETDATE() AS DATE) AS datetime))))) AS MONEY)
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(10, '03 Producción','Diferida BBDP:',isnull( CONVERT(VARCHAR,  CAST(@DifBruta  AS MONEY), 1),0) )
			
			SELECT @DifNeta = CAST((SELECT    SUM( PR_ParoDetalle.ProduccionDiferida) 
				FROM         PR_Paro INNER JOIN
									  PR_ParoDetalle ON PR_Paro.Id = PR_ParoDetalle.IdParo INNER JOIN
									  PR_Pozo ON PR_Paro.Pozo = PR_Pozo.Id INNER JOIN
									  PR_Estacion ON PR_Pozo.Estacion = PR_Estacion.Id INNER JOIN
									  PR_Ramal ON PR_Estacion.Ramal = PR_Ramal.Id INNER JOIN
									  PR_ListaGeneral ON PR_Pozo.TipoSistema = PR_ListaGeneral.Id INNER JOIN
									  PR_RubroParo ON PR_Paro.Motivo = PR_RubroParo.Id
				WHERE     (PR_ParoDetalle.Inicio >= DATEADD(HOUR, 5, CAST(CAST(GETDATE() AS DATE) AS datetime))) AND (PR_ParoDetalle.Inicio < DATEADD(DAY, 1, DATEADD(hour, 5, 
									  CAST(CAST(GETDATE() AS DATE) AS datetime)))))AS MONEY) 
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(11, '03 Producción','Diferida BNDP:',isnull(CONVERT(VARCHAR,  CAST(@DifNeta  AS MONEY), 1),0)  )						 
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(13, '03 Producción','Contable BBDP:', CONVERT(VARCHAR,  CAST(@Bruta -  isnull(CONVERT(VARCHAR,  CAST(@DifBruta  AS MONEY), 1),0)  AS MONEY), 1) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(14, '03 Producción','Contable BNDP:',CONVERT(VARCHAR,  CAST(@Neta  - isnull(CONVERT(VARCHAR,  CAST(@DifNeta  AS MONEY), 1),0)  AS MONEY), 1) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(14, '05 Otros','Ramales:', (select COUNT (1) FROM PR_Ramal where PR_Ramal.Bloque =@id) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(15, '05 Otros','Zonas:', (SELECT     COUNT(1) FROM         PR_Ramal INNER JOIN   PR_Zona ON PR_Ramal.Id = PR_Zona.Ramal
GROUP BY PR_Ramal.Bloque
HAVING      (PR_Ramal.Bloque = @id)) )
					INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(16, '05 Otros','Estaciones:', (SELECT     COUNT(1)
FROM         PR_Estacion INNER JOIN
                      PR_Ramal ON PR_Ramal.Id = PR_Estacion.Ramal
GROUP BY PR_Ramal.Bloque
HAVING      (PR_Ramal.Bloque = @id) ))

		END

		--RAMAL
		IF @instalacion =  2
		BEGIN
		INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(0, '01 General','Clave:', (SELECT  rtrim(Clave)  FROM PR_Ramal  WHERE Id =  @ID ) )
		INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(1, '01 General','Nombre:', (	SELECT  Nombre   FROM PR_Ramal WHERE Id =  @ID )  )

		END

				IF @instalacion =  3
		BEGIN
		INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(0, '01 General','Clave:', (SELECT  rtrim(Clave)  FROM  PR_zona  WHERE Id =  @ID ) )
		INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(1, '01 General','Nombre:', (	SELECT  Nombre   FROM PR_zona WHERE Id =  @ID )  )


		END
		
			IF @instalacion = 4
		BEGIN
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(0, '01 General','Clave:', (SELECT  rtrim(Clave)  FROM PR_Estacion  WHERE Id =  @ID ) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(1, '01 General','Nombre:', (	SELECT  Nombre   FROM PR_Estacion WHERE Id =  @ID )  )

		END
		
		
		
		IF @instalacion = 5
		BEGIN
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(0, '01 General','Clave:', (SELECT  rtrim(Clave)  FROM PR_Pozo WHERE Id =  @ID ) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(1, '01 General','Nombre:', (	SELECT  Nombre   FROM PR_Pozo WHERE Id =  @ID )  )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(2, '02 Situación','Estado:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.Estatus = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(3, '02 Situación','Sub Estado:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.SubEstado  = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )
			INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(4, '02 Situación','Sistema:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.TipoSistema  = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )			
			
			select @parosactivos =0 
			select @parosactivos = count (*) from PR_Paro where pozo = @ID and Finalizado = 0

			if (@parosactivos >0)
			begin
				select  @idparo =  PR_Paro.Id  from PR_paro where   pozo = @ID and Finalizado = 0
				select @rubroparo =  PR_paro.Motivo from PR_paro where id = @idparo  
				INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(9, '02 Situación','Rubro Paro:', (SELECT    PR_RubroParo.Rubros  FROM     PR_RubroParo  WHERE  PR_RubroParo.Id = @rubroparo    ) )			
				INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(10, '02 Situación','Rubro Tipo:', (SELECT    PR_RubroParo.Tipo   FROM    PR_RubroParo  WHERE  PR_RubroParo.Id = @rubroparo    ) )		
	
			end

	INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor) VALUES (5, '01 General','Tipo Producción:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.TipoProduccion   = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )		
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(6, '01 General','Act. Incremental:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.ActividadIncremental    = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )		
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(7, '01 General','Año Actividad:', (SELECT    anioactividad from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(8, '02 Situación','LDD:', (SELECT  cASe   LDD  when 1 then 'Sí' when 0 then 'No' end  from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(9, '01 General','Pozo Tipo:', (SELECT     PR_ListaGeneral.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_ListaGeneral ON PR_Pozo.PozoTipo     = PR_ListaGeneral.Id
WHERE     (PR_Pozo.Id = @id) ) )		
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(10, '03 Ubicación','X:', (SELECT  CONVERT(VARCHAR,  CAST(X AS MONEY), 1)  from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(11, '03 Ubicación','Y:', (SELECT   CONVERT(VARCHAR,   CAST(y  AS MONEY ) , 1)  from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	

INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(12, '03 Ubicación','Campo:', (SELECT     PR_Campo.Nombre
FROM         PR_Pozo INNER JOIN
                      PR_Campo ON PR_Pozo.Campo = PR_Campo.Id
GROUP BY PR_Campo.Nombre, PR_Pozo.Id
HAVING      (PR_Pozo.Id = @id)) )	

INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(13, '04 Producción','BBDP:', (SELECT  CONVERT(VARCHAR,  CAST(PR_Pozo.ProduccionBruta  AS MONEY), 1)  from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(14, '04 Producción','% Agua:', (SELECT   CONVERT(VARCHAR,   CAST(PR_Pozo.PorcentajeAgua   AS MONEY ) , 1)   from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(15, '04 Producción','BBNP:', (SELECT  CONVERT(VARCHAR,  CAST(PR_Pozo.ProduccionNeta   AS MONEY), 1)  from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(15, '04 Producción','Ultimo Control:',(select  CAST ( UltimoControl AS date ) from         PR_Pozo
WHERE     (PR_Pozo.Id = @id) ) )	
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(16, '01 General','Clave OFM:', (	SELECT  OFM   FROM PR_Pozo WHERE Id =  @ID )  )
INSERT INTO @Tabla_Temp (Indice ,Categoria , Etiqueta  , Valor)VALUES(16, '01 General','Comentarios:', (	SELECT  Comentarios    FROM PR_Pozo WHERE Id =  @ID )  )
		END
	
	SELECT Indice ,Categoria , Etiqueta  , Valor from @Tabla_Temp  order by Indice 

END
