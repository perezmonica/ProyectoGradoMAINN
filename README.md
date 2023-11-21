# Proyecto Grado para la Maestría en Analitica para la Inteligencia de los Negocios
## Digital Twin para la Gestión de Transporte Público: Análisis del Flujo de Articulados en TransMilenio por la Troncal Calle 26
*Mónica Juliana Pérez Morales* 
perezmonica@javeriana.edu.co

## Resumen
El presente trabajo detalla la construcción de un modelo de Digital Twin (DT) del sistema de transporte TransMilenio en Bogotá, enfocado específicamente en la Troncal de la Calle 26. Se aborda desde la adquisición y preparación de datos hasta la implementación y evaluación del modelo. Los datos se obtienen de fuentes GTFS y se manipulan para reflejar con precisión las estaciones y rutas de la troncal mencionada. Se realizan pruebas de estacionariedad y se emplea el análisis de series de tiempo para predecir patrones de tráfico, utilizando modelos ARIMA para estimar la congestión y flujo de pasajeros.
La implementación del DT se realiza en NetLogo, un entorno de modelado multiagente que facilita la simulación de sistemas complejos. En este entorno, se simulan las dinámicas de los autobuses y estaciones, utilizando un MAS (Sistema Multi-agente) que sigue un enfoque basado en la metodología GAIA. Este enfoque permite la coordinación de entidades decisionales locales (autobuses y estaciones) y globales (coordinadores del sistema), así como la integración de predicciones para adaptar la operación simulada a las condiciones cambiantes.
El modelo DT se evalúa demostrando su capacidad para replicar con precisión el comportamiento del sistema de transporte real, especialmente durante las horas pico. Los resultados muestran que el DT es capaz de reflejar de manera efectiva la dinámica operacional del TransMilenio, validando el enfoque de simulación y la integración de datos analíticos en la toma de decisiones y planificación estratégica

## Abstract
This workdetails the construction of a Digital Twin (DT) model of the TransMilenio transportation system in Bogotá, specifically focused on the Calle 26 Trunk. It covers from data acquisition and preparation to model implementation and evaluation. Data are obtained from GTFS sources and manipulated to accurately reflect the stations and routes of the trunk. Stationarity tests are performed and time series analysis is employed to predict traffic patterns, using ARIMA models to estimate congestion and passenger flow.
The DT implementation is performed in NetLogo, a multi-agent modeling environment that facilitates the simulation of complex systems. In this environment, bus and station dynamics are simulated using a MAS (Multi-Agent System) that follows an approach based on the GAIA methodology. This approach allows the coordination of local (buses and stations) and global (system coordinators) decisional entities, as well as the integration of predictions to adapt the simulated operation to changing conditions.
The DT model is evaluated by demonstrating its ability to accurately replicate the behavior of the real transportation system, especially during peak hours. The results show that the DT is able to effectively reflect the operational dynamics of TransMilenio, validating the simulation approach and the integration of analytical data in decision making and strategic planning.


## Requiriments 
* [Python](http://www.python.org) version >= 3.7;
* [Numpy](http://www.numpy.org), the core numerical extensions for linear algebra and multidimensional arrays;
* [Pandas](http://pandas.pydata.org/), Python version of R dataframe;
* [Geopandas] (https://geopandas.org/en/stable/), to get analysis in geospatial information;
* [Matplotlib](http://matplotlib.sf.net), plotting and graphing libraries;

## Documents and Models

